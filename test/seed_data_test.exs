defmodule SeedDataTest do
  use ExUnit.Case, async: true
  import Ecto.Query, only: [from: 2]
  alias ChercheVille.SeedData

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(ChercheVille.Repo)
  end

  test "import data" do
    SeedData.import_data(["ZZ"])

    query = from(
      c in ChercheVille.City,
      where: c.name == "Brussels"
    )
    brussels = query |> ChercheVille.Repo.one
    assert %ChercheVille.City{population: 1019022} = brussels
  end
end
