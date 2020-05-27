import Config

config :chercheville, ChercheVille.Repo,
  database: System.get_env("DB_NAME", "cities"),
  username: System.fetch_env!("DB_USERNAME"),
  password: System.fetch_env!("DB_PASSWORD"),
  hostname:  System.get_env("DB_HOST", "localhost")

port = System.get_env("PORT", "4000") |> String.to_integer()

config :chercheville,
  http_port: port,
  default_country_code: System.get_env("DEFAULT_COUNTRY_CODE", "FR")

config :logger, level: :info
