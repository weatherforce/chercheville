defmodule ChercheVille.City do
  @moduledoc """
  Ecto schema representing a city.
  """
  use Ecto.Schema

  @primary_key {:geonameid, :integer, autogenerate: false}

  schema "cities" do
    field(:name, :string)
    field(:asciiname, :string)
    field(:alternatenames, :string)
    field(:geom, Geo.PostGIS.Geometry)
    field(:country_code, :string)
    field(:admin1_code, :string)
    field(:admin2_code, :string)
    field(:admin1_name, :string)
    field(:admin2_name, :string)
    field(:population, :integer)
  end

  def changeset(city, params \\ %{}) do
    Ecto.Changeset.cast(city, params, [
      :geonameid,
      :name,
      :asciiname,
      :alternatenames,
      :geom,
      :country_code,
      :admin1_code,
      :admin2_code,
      :admin1_name,
      :admin2_name,
      :population
    ])
  end
end
