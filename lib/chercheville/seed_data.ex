defmodule ChercheVille.SeedData do
  @moduledoc """
  Loading data from the geonames text files into our database.
  """
  @app :chercheville
  @start_apps [:crypto, :ssl, :postgrex, :ecto]

  @base_url "http://download.geonames.org/export/dump/"
  @places_headers ~w{
      geonameid         
      name              
      asciiname         
      alternatenames    
      latitude          
      longitude         
      feature_class     
      feature_code      
      country_code      
      cc2               
      admin1_code       
      admin2_code       
      admin3_code       
      admin4_code       
      population        
      elevation         
      dem               
      timezone          
      modification_date 
    }

  defp fetcher do
    Application.get_env(@app, :fetcher, ChercheVille.HTTPFetcher)
  end

  defp data_dir do
    Application.get_env(@app, :data_dir, "./geonames_data/")
  end

  @doc """
  Run database migrations
  """
  def migrate do
    for repo <- repos() do
      {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :up, all: true))
    end
  end

  @doc """
  Database migration rollback
  """
  def rollback(repo, version) do
    {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :down, to: version))
  end

  defp repos do
    Application.load(@app)
    Application.fetch_env!(@app, :ecto_repos)
  end

  @doc """
  Fetch data for countries specified by `country_codes` and store it locally.
  """
  def fetch_data(country_codes \\ []) do
    load_config()
    country_codes = Application.get_env(@app, :country_codes, country_codes)

    if length(country_codes) < 1 do
      IO.puts("*** No country codes specified ***")
    else
      File.mkdir(data_dir())

      fetcher().start()

      fetch_file("admin1CodesASCII.txt")
      fetch_file("admin2Codes.txt")

      Enum.each(country_codes, fn country_code ->
        fetch_file(country_code <> ".zip") |> unzip
      end)
    end
  end

  defp unzip(filename) do
    to_charlist(filename) |> :zip.unzip(cwd: data_dir())
  end

  defp fetch_file(filename) do
    destination_filename = data_dir() <> filename

    if File.exists?(destination_filename) do
      IO.puts("#{destination_filename} already exists")
    else
      url = @base_url <> filename
      IO.puts("Download #{url}")
      %HTTPotion.Response{body: body, status_code: 200} = fetcher().get(url)
      File.write(destination_filename, body)
    end

    destination_filename
  end

  @doc """
  Load cities data from files that have been previously fetched with
  `fetch_data/1` and insert this data into our database.
  """
  def insert_data(country_codes \\ []) do
    load_config()
    start_repo()
    country_codes = Application.get_env(@app, :country_codes, country_codes)

    if length(country_codes) < 1 do
      IO.puts("*** No country codes specified ***")
    else
      Application.ensure_all_started(@app)
      admin1_codes = read_admin_codes("admin1CodesASCII.txt")
      admin2_codes = read_admin_codes("admin2Codes.txt")
      import_countries(country_codes, admin1_codes, admin2_codes)
    end
  end

  @doc """
  Fetch data for countries specified by `country_codes` and insert this data into our database.
  """
  def import_data(country_codes \\ []) do
    fetch_data(country_codes)
    insert_data(country_codes)
  end

  defp import_countries(country_codes, admin1_codes, admin2_codes) do
    for country_code <- country_codes do
      import_country(country_code, admin1_codes, admin2_codes)
    end
  end

  defp import_country(country_code, admin1_codes, admin2_codes) do
    IO.puts("Importing data for country #{country_code}")
    filename = data_dir() <> country_code <> ".txt"

    places = stream_csv(filename)
    admin1_codes = localize_admin_names(admin1_codes, places)

    places = stream_csv(filename)

    places
    |> filter_cities
    |> filter_has_admin2
    |> filter_out_sections_of_populated_places
    |> add_admin1_names(country_code, admin1_codes)
    |> add_admin2_names(country_code, admin2_codes)
    |> insert_into_database
  end

  defp localize_admin_names(admin_codes, places) do
    admin_geonameids = geonameids_from_admin_code_map(admin_codes)
    admin_places_map = places_map_for_geonameids(places, admin_geonameids)

    for {code, attributes} <- admin_codes, into: %{} do
      geonameid = attributes["geonameid"]
      admin_place = admin_places_map[geonameid]

      attributes =
        if admin_place do
          Map.put(attributes, "name", admin_place["name"])
        else
          attributes
        end

      {code, attributes}
    end
  end

  defp geonameids_from_admin_code_map(admin_codes) do
    for {_code, attributes} <- admin_codes, into: MapSet.new() do
      attributes["geonameid"]
    end
  end

  defp places_map_for_geonameids(places, geonameids) do
    for place <- places, place["geonameid"] in geonameids, into: %{} do
      {place["geonameid"], place}
    end
  end

  defp stream_csv(filename) do
    open_binstream(filename)
    |> CSV.decode(separator: ?\t, headers: @places_headers)
    |> Stream.filter(fn
      {:ok, _} -> true
      _ -> false
    end)
    |> Stream.map(fn {:ok, row} ->
      {latitude, _} = Float.parse(row["latitude"])
      {longitude, _} = Float.parse(row["longitude"])
      point = %Geo.Point{coordinates: {latitude, longitude}, srid: 4326}

      row
      |> Map.put("geom", point)
      |> Map.delete("latitude")
      |> Map.delete("longitude")
    end)
  end

  defp filter_cities(rows) do
    # P    | city, village,...
    Stream.filter(rows, &(&1["feature_class"] == "P"))
  end

  defp filter_has_admin2(rows) do
    Stream.filter(rows, &(&1["admin2_code"] != ""))
  end

  defp filter_out_sections_of_populated_places(rows) do
    digit_regexp = ~r/\d/

    rows
    |> Stream.reject(
      # Code reference: http://www.geonames.org/export/codes.html
      &(&1["feature_code"] in ["PPLX", "PPLH"] or Regex.match?(digit_regexp, &1["name"]))
    )
  end

  defp insert_into_database(cities) do
    columns = [
      "geonameid",
      "name",
      "asciiname",
      "alternatenames",
      "geom",
      "country_code",
      "admin1_code",
      "admin2_code",
      "admin1_name",
      "admin2_name",
      "population"
    ]

    lines =
      for city <- cities do
        values = for column <- columns, do: city[column]
        Enum.join(values, "\t") <> "\n"
      end

    sql_columns = Enum.join(columns, ", ")
    sql = "COPY cities(#{sql_columns}) FROM STDIN"
    stream = Ecto.Adapters.SQL.stream(ChercheVille.Repo, sql)
    timeout = Application.fetch_env!(:chercheville, :import_timeout)
    ChercheVille.Repo.transaction(fn -> Enum.into(lines, stream) end, timeout: timeout)
  end

  defp add_admin1_names(rows, country_code, admin1_codes) do
    Stream.map(rows, fn row ->
      key = "#{country_code}.#{row["admin1_code"]}"
      admin1_name = admin1_codes[key]["name"]
      Map.put(row, "admin1_name", admin1_name)
    end)
  end

  defp add_admin2_names(rows, country_code, admin2_codes) do
    Stream.map(rows, fn row ->
      key = "#{country_code}.#{row["admin1_code"]}.#{row["admin2_code"]}"
      admin2_name = admin2_codes[key]["name"]
      Map.put(row, "admin2_name", admin2_name)
    end)
  end

  defp read_admin_codes(filename) do
    open_binstream(data_dir() <> filename)
    |> CSV.decode(separator: ?\t, headers: ["code", "name", "asciiname", "geonameid"])
    |> Enum.reduce(%{}, fn
      {:ok, row}, map -> Map.put(map, row["code"], row)
      {:error, _}, map -> map
    end)
  end

  defp open_binstream(filename) do
    # Instead of creating a stream directly with File.stream!/1, we use
    # IO.binstream/2 to create a raw binary stream, which makes it a lot
    # faster.
    #
    # For example, to import data for Germany it went from about half an hour
    # to about 2 minutes and half.
    #
    # See https://elixirforum.com/t/help-with-performance-file-io/802/36
    File.open!(filename) |> IO.binstream(:line)
  end

  defp load_config, do: Application.load(@app)

  defp start_repo, do: Enum.each(@start_apps, &Application.ensure_all_started/1)
end
