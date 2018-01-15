defmodule CityFTS.Repo.Migrations.CreateCities do
  use Ecto.Migration

  def change do
    create table(:cities, primary_key: false) do
      add :geonameid, :integer, primary_key: true
      add :name, :string, null: false
      add :asciiname, :string, null: false
      add :alternatenames, :string, size: 10000
      add :latitude, :float, null: false
      add :longitude, :float, null: false
      add :country_code, :string, size: 2, null: false
      add :admin1_code, :string, size: 20
      add :admin2_code, :string, size: 80
      add :admin1_name, :string, null: false
      add :admin2_name, :string, null: false
    end
  end
end
