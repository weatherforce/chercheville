import Config

# Importing data for large countries such as India may trigger the default
# timeout of 15000ms
db_timeout_from_env = System.get_env("DB_TIMEOUT")

db_timeout =
  if is_nil(db_timeout_from_env) do
    # default to 5 minutes (in milliseconds)
    5 * 60 * 1000
  else
    String.to_integer(db_timeout_from_env)
  end

config :chercheville, ChercheVille.Repo,
  database: System.get_env("DB_NAME", "cities"),
  username: System.fetch_env!("DB_USERNAME"),
  password: System.fetch_env!("DB_PASSWORD"),
  hostname: System.get_env("DB_HOST", "localhost"),
  timeout: db_timeout

port = System.get_env("PORT", "4000") |> String.to_integer()

config :chercheville,
  http_port: port,
  default_country_code: System.get_env("DEFAULT_COUNTRY_CODE", "FR")

config :logger, level: :info
