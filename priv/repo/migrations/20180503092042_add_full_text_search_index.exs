defmodule ChercheVille.Repo.Migrations.AddFullTextSearchIndex do
  use Ecto.Migration

  def change do
    execute("""
    CREATE OR REPLACE FUNCTION gin_fts_fct(name text)
      RETURNS tsvector
    AS
    $BODY$
      SELECT to_tsvector(unaccent($1));
    $BODY$
    LANGUAGE sql
    IMMUTABLE;
    """)

    execute("CREATE INDEX cities_fts ON cities USING gin(gin_fts_fct(name))")
  end
end
