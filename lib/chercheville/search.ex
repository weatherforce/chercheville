defmodule ChercheVille.Search do
  use GenServer

  def init(args) do
    {:ok, args}
  end

  def start_link(state \\ []), do: GenServer.start_link(__MODULE__, state, name: __MODULE__)

  def text(search_string, limit \\ 10) when is_binary(search_string),
    do: GenServer.call(__MODULE__, {:text, search_string, limit})

  def coordinates(latitude, longitude, limit \\ 10)
      when is_number(latitude) and is_number(longitude),
      do: GenServer.call(__MODULE__, {:coordinates, latitude, longitude, limit})

  def handle_call({:text, search_string, limit}, from, state) do
    require Ecto.Query

    spawn(fn ->
      query =
        Ecto.Query.from(
          city in ChercheVille.City,
          where: ilike(city.name, ^"#{search_string}%"),
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
