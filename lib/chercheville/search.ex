defmodule ChercheVille.Search do
  @moduledoc """
  A GenServer providing city search capabilities.
  """
  use GenServer
  import Ecto.Query, only: [from: 2]

  def init(args) do
    {:ok, args}
  end

  def start_link(state \\ []), do: GenServer.start_link(__MODULE__, state, name: __MODULE__)

  @doc """
  Search for cities matching `search_string`.

  Returns a list of `ChercheVille.City` records no larger than `limit`.
  Equally relevant cities get sorted by descending population.
  """
  def text(search_string, opts \\ []) when is_binary(search_string) do
    limit = Keyword.get(opts, :limit, 10)
    country_code = Keyword.get(opts, :country_code)
    GenServer.call(__MODULE__, {:text, search_string, limit, country_code})
  end

  @doc """
  Search cities nearest to `latitude` and `longitude`.

  Returns a list of `ChercheVille.City` records no larger than `limit`
  and sorted by distance from `latitude` and `longitude`.
  """
  def coordinates(latitude, longitude, opts \\ [])
      when is_number(latitude) and is_number(longitude) do
    limit = Keyword.get(opts, :limit, 10)
    country_code = Keyword.get(opts, :country_code)
    GenServer.call(__MODULE__, {:coordinates, latitude, longitude, limit, country_code})
  end

  def nearest_city_coordinates(latitude, longitude) do
    [city | _] = ChercheVille.Search.coordinates(latitude, longitude, limit: 1)
    {city[:latitude], city[:longitude]}
  end

  def handle_call({:text, search_string, limit, country_code}, from, state) do

    spawn(fn ->
      query =
        from(
          city in ChercheVille.City,
          where:
            fragment(
              "immutable_unaccent(?) % immutable_unaccent(?)",
              ^search_string,
              city.name
            ),
          limit: ^limit,
          order_by: [
            desc:
              fragment(
                "similarity(immutable_unaccent(?), immutable_unaccent(?))",
                ^search_string,
                city.name
              ),
            desc: city.population
          ]
        )

      cities = query
               |> filter_by_country(country_code)
               |> ChercheVille.Repo.all()
               |> geom_to_coordinates
      GenServer.reply(from, cities)
    end)

    {:noreply, state}
  end

  def handle_call({:coordinates, latitude, longitude, limit, country_code}, from, state) do
    import Geo.PostGIS
    point = %Geo.Point{coordinates: {latitude, longitude}, srid: 4326}

    spawn(fn ->
      query =
        from(
          city in ChercheVille.City,
          limit: ^limit,
          order_by: [asc: st_distance(city.geom, ^point)]
        )

      cities = query
               |> filter_by_country(country_code)
               |> ChercheVille.Repo.all()
               |> geom_to_coordinates
      GenServer.reply(from, cities)
    end)

    {:noreply, state}
  end

  defp filter_by_country(query, country_code) when not is_nil(country_code) do
    from city in query, where: city.country_code == ^country_code
  end
  defp filter_by_country(query, _), do: query

  defp geom_to_coordinates(cities) do
    # Convert PostGIS geometry field to distinct latitude and longitude fields
    cities
    |> Enum.map(fn city ->
      %Geo.Point{coordinates: {latitude, longitude}} = Map.get(city, :geom)

      Map.from_struct(city)
      |> Map.put(:latitude, latitude)
      |> Map.put(:longitude, longitude)
      |> Map.delete(:geom)
    end)
  end
end
