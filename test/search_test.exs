defmodule SearchTest do
  use ExUnit.Case, async: true

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(ChercheVille.Repo)
    Ecto.Adapters.SQL.Sandbox.mode(ChercheVille.Repo, {:shared, self()})
  end

  defp insert_city(geonameid, name, latitude \\ 43, longitude \\ 1) do
    point = %Geo.Point{ coordinates: {latitude, longitude}, srid: 4326}
    city = %{
      "geonameid": geonameid,
      "name": name,
      "asciiname": "Toulouse",
      "alternatenames": "Touluse",
      "geom": point,
      "country_code": "FR",
      "admin1_code": "",
      "admin2_code": "",
      "admin1_name": "a",
      "admin2_name": "b",
      "population": 400_000
    }
    changeset = ChercheVille.City.changeset(%ChercheVille.City{}, city)
    ChercheVille.Repo.insert!(changeset)
  end

  test "start substring" do
    insert_city(123930305, "Toulouse")
    [%{geonameid: geonameid} | _] = ChercheVille.Search.text("toul")
    assert geonameid == 123930305
  end

  test "nearest to coordinates" do
    insert_city(123930305, "foo", 2, 20)
    insert_city(123930306, "bar", 42, 0)
    [%{geonameid: geonameid} | _] = ChercheVille.Search.coordinates(43, 1)
    assert geonameid == 123930306
  end

  test "geom converted to latitude and longitude" do
    insert_city(123930305, "foo", 2, 20)
    [city | _] = ChercheVille.Search.text("foo")
    assert city[:latitude] == 2
    assert city[:longitude] == 20
    assert is_nil(city[:geom])
  end
end
