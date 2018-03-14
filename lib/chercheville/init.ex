Postgrex.Types.define(
  ChercheVille.PostgresTypes,
  [Geo.PostGIS.Extension] ++ Ecto.Adapters.Postgres.extensions()
)

use Mix.Config
config :chercheville, ChercheVille.Repo, types: ChercheVille.PostgresTypes
