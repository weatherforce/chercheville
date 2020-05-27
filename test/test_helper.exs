ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(ChercheVille.Repo, :manual)

Mox.defmock(ChercheVille.FetcherMock, for: ChercheVille.Fetcher)

defmodule TestHelper do
  def insert_city(geonameid, name, latitude \\ 43, longitude \\ 1, country_code \\ "FR") do
    point = %Geo.Point{coordinates: {latitude, longitude}, srid: 4326}

    city = %{
      geonameid: geonameid,
      name: name,
      asciiname: "Toulouse",
      alternatenames: "Touluse",
      geom: point,
      country_code: country_code,
      admin1_code: "",
      admin2_code: "",
      admin1_name: "a",
      admin2_name: "b",
      population: 400_000
    }

    changeset = ChercheVille.City.changeset(%ChercheVille.City{}, city)
    ChercheVille.Repo.insert!(changeset)
  end
end
