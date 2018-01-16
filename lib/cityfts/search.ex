defmodule CityFTS.Search do
  use GenServer

  def start_link(state \\ []), do:
    GenServer.start_link(__MODULE__, state, name: {:global, __MODULE__})

  def query(server, search_string, limit \\ 10) when is_binary(search_string), do:
    GenServer.call(server, {:query, search_string, limit})

  def handle_call({:query, search_string, limit}, _from, state) do
    require Ecto.Query

    query = Ecto.Query.from(
      city in CityFTS.City,
      where: ilike(city.name, ^"#{search_string}%"),
      limit: ^limit,
      order_by: [desc: city.population]
    )
    cities = query |> CityFTS.Repo.all
    {:reply, cities, state}
  end

end
