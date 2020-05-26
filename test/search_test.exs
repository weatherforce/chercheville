defmodule SearchTest do
  use ExUnit.Case, async: true
  import TestHelper

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(ChercheVille.Repo)
    Ecto.Adapters.SQL.Sandbox.mode(ChercheVille.Repo, {:shared, self()})
  end

  test "start substring" do
    insert_city(123_930_305, "Toulouse")
    [%{geonameid: geonameid} | _] = ChercheVille.Search.text("toul")
    assert geonameid == 123_930_305
  end

  test "test diacritic" do
    insert_city(123_930_305, "Labège")
    [%{geonameid: geonameid} | _] = ChercheVille.Search.text("labè")
    assert geonameid == 123_930_305
  end

  test "test diacritic missing" do
    insert_city(123_930_305, "Labège")
    [%{geonameid: geonameid} | _] = ChercheVille.Search.text("labe")
    assert geonameid == 123_930_305
  end

  test "test complete name words" do
    insert_city(123_930_305, "Saint-Juéry")
    [%{geonameid: geonameid} | _] = ChercheVille.Search.text("saint juéry")
    assert geonameid == 123_930_305
  end

  test "test partial name words" do
    insert_city(123_930_305, "Saint-Juéry")
    [%{geonameid: geonameid} | _] = ChercheVille.Search.text("saint jue")
    assert geonameid == 123_930_305
  end

  test "test complte name with hyphen" do
    insert_city(123_930_305, "Saint-Juéry")
    [%{geonameid: geonameid} | _] = ChercheVille.Search.text("saint-juéry")
    assert geonameid == 123_930_305
  end

  test "test typo" do
    insert_city(123_930_305, "Montpellier")
    [%{geonameid: geonameid} | _] = ChercheVille.Search.text("montpelier")
    assert geonameid == 123_930_305
  end

  test "nearest to coordinates" do
    insert_city(123_930_305, "foo", 2, 20)
    insert_city(123_930_306, "bar", 42, 0)
    [%{geonameid: geonameid} | _] = ChercheVille.Search.coordinates(43, 1)
    assert geonameid == 123_930_306
  end

  test "find coordinates of nearest city" do
    insert_city(123_930_305, "foo", 2, 20)
    insert_city(123_930_306, "bar", 42, 0)
    coordinates = ChercheVille.Search.nearest_city_coordinates(43, 1)
    assert coordinates == {42, 0}
  end

  test "geom converted to latitude and longitude" do
    insert_city(123_930_305, "foo", 2, 20)
    [city | _] = ChercheVille.Search.text("foo")
    assert city[:latitude] == 2
    assert city[:longitude] == 20
    assert is_nil(city[:geom])
  end

  test "filter text search by country" do
    insert_city(123_930_305, "foo", 2, 20, "FR")
    insert_city(123_930_306, "foo", 2, 20, "PL")

    results = ChercheVille.Search.text("foo", country_code: "FR")

    assert length(results) == 1
    [city | _] = results
    assert city[:geonameid] == 123_930_305
  end

  test "filter coordinates search by country" do
    insert_city(123_930_305, "foo", 2, 20, "FR")
    insert_city(123_930_306, "foo", 2, 20, "PL")

    results = ChercheVille.Search.coordinates(2, 20, country_code: "FR")

    assert length(results) == 1
    [city | _] = results
    assert city[:geonameid] == 123_930_305
  end
end
