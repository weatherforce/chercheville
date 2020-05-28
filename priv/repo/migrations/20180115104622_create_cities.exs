defmodule ChercheVille.Repo.Migrations.CreateCities do
  use Ecto.Migration

  def change do

    execute "CREATE EXTENSION IF NOT EXISTS postgis"
    execute "CREATE EXTENSION IF NOT EXISTS unaccent"
    execute "CREATE EXTENSION IF NOT EXISTS pg_trgm"

    create table(:cities, primary_key: false) do
      add :geonameid, :integer, primary_key: true
      add :name, :string, null: false
      add :asciiname, :string, null: false
      add :alternatenames, :string, size: 10000
      add :geom, :geometry, null: false
      add :country_code, :string, size: 2, null: false
      add :admin1_code, :string, size: 20
      add :admin2_code, :string, size: 80
      add :admin1_name, :string, null: false
      add :admin2_name, :string, null: false
      add :population, :integer, null: false
    end
  end
end
