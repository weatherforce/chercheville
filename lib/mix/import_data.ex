defmodule Mix.Tasks.ImportData do
  use Mix.Task
  import Mix.Ecto

  @data_dir File.cwd!() <> "/geonames_data/"
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

  @shortdoc "Import data files from geonames.org into the database"
  def run(country_codes) do
    ensure_started(CityFTS.Repo, [])
    admin1_codes = read_admin_codes("admin1CodesASCII.txt")
    admin2_codes = read_admin_codes("admin2Codes.txt")
    import_countries(country_codes, admin1_codes, admin2_codes)
  end

  defp import_countries(country_codes, admin1_codes, admin2_codes) do
    Enum.each(country_codes, &import_country(&1, admin1_codes, admin2_codes))
  end

  defp import_country(country_code, admin1_codes, admin2_codes) do
    filename = @data_dir <> country_code <> ".txt"
    read_csv(filename)
    |> filter_cities
    |> filter_has_admin2
    |> add_admin1_names(country_code, admin1_codes)
    |> add_admin2_names(country_code, admin2_codes)
    |> IO.inspect
    |> insert_into_database
  end

  defp read_csv(filename) do
    File.stream!(filename)
    |> CSV.decode(separator: ?\t, headers: @places_headers)
    |> Stream.filter(fn
      {:ok, _} -> true
      _ -> false
    end)
    |> Stream.map(fn({:ok, row}) -> row end)
  end

  defp filter_cities(rows) do
    Stream.filter(rows, &(&1["feature_class"] == "P"))
  end

  defp filter_has_admin2(rows) do
    Stream.filter(rows, &(&1["admin2_code"] != ""))
  end

  defp insert_into_database(cities) do
    Enum.each(cities, fn(city) ->
      changeset = CityFTS.City.changeset(%CityFTS.City{}, city)
      CityFTS.Repo.insert(changeset)
    end)
  end

  defp add_admin1_names(rows, country_code, admin1_codes) do
    Stream.map(rows, fn(row) ->
      key = "#{country_code}.#{row["admin1_code"]}"
      admin1_name = admin1_codes[key]["name"]
      Map.put(row, "admin1_name", admin1_name)
    end)
  end

  defp add_admin2_names(rows, country_code, admin2_codes) do
    Stream.map(rows, fn(row) ->
      key = "#{country_code}.#{row["admin1_code"]}.#{row["admin2_code"]}"
      admin2_name = admin2_codes[key]["name"]
      Map.put(row, "admin2_name", admin2_name)
    end)
  end

  defp read_admin_codes(filename) do
    File.stream!(@data_dir <> filename)
    |> CSV.decode(separator: ?\t, headers: ["code", "name", "asciiname", "geonameid"])
    |> Enum.reduce(%{}, fn
      {:ok, row}, map -> Map.put(map, row["code"], row)
      {:error, _}, map -> map
    end)
  end
end
