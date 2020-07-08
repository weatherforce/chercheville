defmodule ChercheVille.Repo.Migrations.AddTrgmIndex do
  use Ecto.Migration

  def change do
      execute("""
      CREATE OR REPLACE FUNCTION immutable_unaccent(name text)
        RETURNS text
      AS
      $BODY$
        SELECT public.unaccent($1);
      $BODY$
      LANGUAGE sql
      IMMUTABLE;
      """)

      execute("""
      CREATE INDEX cities_name_trgm_idx ON cities USING GIN (immutable_unaccent(name) gin_trgm_ops);
      """)
  end
end
