defmodule ChercheVille.Search do
  use GenServer

  def init(args) do
    {:ok, args}
  end

  def start_link(state \\ []), do:
    GenServer.start_link(__MODULE__, state, name: __MODULE__)

  def text(search_string, limit \\ 10) when is_binary(search_string), do:
    GenServer.call(__MODULE__, {:text, search_string, limit})

  def coordinates(latitude, longitude, limit \\ 10) when is_number(latitude) and is_number(longitude), do:
    GenServer.call(__MODULE__, {:coordinates, latitude, longitude, limit})

  def handle_call({:text, search_string, limit}, _from, state) do
    require Ecto.Query

    query = Ecto.Query.from(
      city in ChercheVille.City,
      where: ilike(city.name, ^"#{search_string}%"),
      limit: ^limit,
      order_by: [desc: city.population]
    )
    cities = query |> ChercheVille.Repo.all
    {:reply, cities, state}
  end

  def handle_call({:coordinates, latitude, longitude, limit}, _from, state) do
    require Ecto.Query
    import Geo.PostGIS
    point = %Geo.Point{ coordinates: {latitude, longitude}, srid: 4326}

    query = Ecto.Query.from(
      city in ChercheVille.City,
      limit: ^limit,
      order_by: [asc: st_distance(city.geom, ^point)]
    )
    cities = query |> ChercheVille.Repo.all
    {:reply, cities, state}
  end

end
