defmodule ChercheVille.Search do
  @moduledoc """
  A GenServer providing city search capabilities.
  """
  import Ecto.Query, only: [from: 2]

  @doc """
  Search for cities matching `search_string`.

  Returns a list of `ChercheVille.City` records no larger than `limit`.
  Equally relevant cities get sorted by descending population.
  """
  def text(search_string, opts \\ []) when is_binary(search_string) do
    limit = Keyword.get(opts, :limit, 10)
    country_code = Keyword.get(opts, :country_code)

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

    query
    |> filter_by_country(country_code)
    |> ChercheVille.Repo.all()
    |> geom_to_coordinates
  end

  @doc """
  Search cities nearest to `latitude` and `longitude`.

  Returns a list of `ChercheVille.City` records no larger than `limit`
  and sorted by distance from `latitude` and `longitude`.
  """
  def coordinates(latitude, longitude, opts \\ [])
      when is_number(latitude) and is_number(longitude) do
    import Geo.PostGIS
    point = %Geo.Point{coordinates: {latitude, longitude}, srid: 4326}
    limit = Keyword.get(opts, :limit, 10)
    country_code = Keyword.get(opts, :country_code)

    query =
      from(
        city in ChercheVille.City,
        limit: ^limit,
        order_by: [asc: st_distance(city.geom, ^point)]
      )

    query
    |> filter_by_country(country_code)
    |> ChercheVille.Repo.all()
    |> geom_to_coordinates
  end

  @doc """
  Search for city nearest to `latitude` and `longitude` and return its coordinates.
  """
  def nearest_city_coordinates(latitude, longitude) do
    [city | _] = ChercheVille.Search.coordinates(latitude, longitude, limit: 1)
    {city[:latitude], city[:longitude]}
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
