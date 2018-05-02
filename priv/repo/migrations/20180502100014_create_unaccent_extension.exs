defmodule ChercheVille.Repo.Migrations.CreateUnaccentExtension do
  use Ecto.Migration

  def change do
    execute("CREATE EXTENSION unaccent")
  end
end
