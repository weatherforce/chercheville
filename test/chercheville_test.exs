defmodule ChercheVilleTest do
  use ExUnit.Case, async: true

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(ChercheVille.Repo)
    Ecto.Adapters.SQL.Sandbox.mode(ChercheVille.Repo, {:shared, self()})
  end

  defp insert_city(geonameid, name) do
    city = %{
      "geonameid": geonameid,
      "name": name,
      "asciiname": "Toulouse",
      "alternatenames": "Touluse",
      "latitude": 43,
      "longitude": 1,
      "country_code": "FR",
      "admin1_code": "",
      "admin2_code": "",
      "admin1_name": "a",
      "admin2_name": "b",
      "population": 400_000
    }
    changeset = ChercheVille.City.changeset(%ChercheVille.City{}, city)
    {:ok, _} = ChercheVille.Repo.insert(changeset)
    geonameid
  end

  test "greets the world" do
    insert_city(123930305, "Toulouse")
    [%ChercheVille.City{geonameid: geonameid} | _] = ChercheVille.Search.query("toul")
    assert geonameid == 123930305
  end
end
