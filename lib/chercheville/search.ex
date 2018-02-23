defmodule ChercheVille.Search do
  use GenServer

  def init(args) do
    {:ok, args}
  end

  def start_link(state \\ []), do:
    GenServer.start_link(__MODULE__, state, name: __MODULE__)

  def query(search_string, limit \\ 10) when is_binary(search_string), do:
    GenServer.call(__MODULE__, {:query, search_string, limit})

  def handle_call({:query, search_string, limit}, _from, state) do
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

end
