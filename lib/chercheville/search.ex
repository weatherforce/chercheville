defmodule ChercheVille.Search do
  @moduledoc """
  A GenServer providing city search capabilities.
  """
  use GenServer

  def init(args) do
    {:ok, args}
  end

  def start_link(state \\ []), do: GenServer.start_link(__MODULE__, state, name: __MODULE__)

  @doc """
  Search for cities matching `search_string`.

  Returns a list of `ChercheVille.City` records no larger than `limit`.
  Equally relevant cities get sorted by descending population.
  """
  def text(search_string, limit \\ 10) when is_binary(search_string),
    do: GenServer.call(__MODULE__, {:text, search_string, limit})

  @doc """
  Search cities nearest to `latitude` and `longitude`.

  Returns a list of `ChercheVille.City` records no larger than `limit`
  and sorted by distance from `latitude` and `longitude`.
  """
  def coordinates(latitude, longitude, limit \\ 10)
      when is_number(latitude) and is_number(longitude),
      do: GenServer.call(__MODULE__, {:coordinates, latitude, longitude, limit})

  def handle_call({:text, search_string, limit}, from, state) do
    require Ecto.Query

    spawn(fn ->
      tsquery_string = tsquery(search_string)
      query =
        Ecto.Query.from(
          city in ChercheVille.City,
          where: fragment(
            "to_tsquery(unaccent(?)) @@ gin_fts_fct(?)",
            ^tsquery_string, city.name
          ),
          limit: ^limit,
          order_by: [desc: city.population]
        )

      cities = query |> ChercheVille.Repo.all() |> geom_to_coordinates
      GenServer.reply(from, cities)
    end)

    {:noreply, state}
  end

  def handle_call({:coordinates, latitude, longitude, limit}, from, state) do
    require Ecto.Query
    import Geo.PostGIS
    point = %Geo.Point{coordinates: {latitude, longitude}, srid: 4326}

    spawn(fn ->
      query =
        Ecto.Query.from(
          city in ChercheVille.City,
          limit: ^limit,
          order_by: [asc: st_distance(city.geom, ^point)]
        )

      cities = query |> ChercheVille.Repo.all() |> geom_to_coordinates
      GenServer.reply(from, cities)
    end)

    {:noreply, state}
  end

  defp tsquery(search_string) do
    # Prepare PostgreSQL full text search query
    search_string
    |> String.split()           # split search expression into words
    |> Enum.map(&(&1 <> ":*"))  # prefix matching
    |> Enum.join(" <-> ")       # join with "followed by" operator
  end

  defp geom_to_coordinates(cities) do
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
