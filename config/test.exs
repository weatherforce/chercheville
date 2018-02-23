use Mix.Config

config :chercheville, ChercheVille.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: "cities_test",
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
