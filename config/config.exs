# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :chercheville, ChercheVille.Repo,
  types: ChercheVille.PostgresTypes,
  database: "cities",
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  # increase timeout to 5 minutes for importing large countries
  timeout: 5 * 60 * 1000

config :chercheville, ecto_repos: [ChercheVille.Repo]

config :chercheville,
  http_port: 4000,
  default_country_code: "FR"

# This configuration is loaded before any dependency and is restricted
# to this project. If another project depends on this project, this
# file won't be loaded nor affect the parent project. For this reason,
# if you want to provide default values for your application for
# 3rd-party users, it should be done in your "mix.exs" file.

# You can configure your application as:
#
#     config :chercheville, key: :value
#
# and access this configuration in your application as:
#
#     Application.get_env(:chercheville, :key)
#
# You can also configure a 3rd-party app:
#
#     config :logger, level: :info
#

# It is also possible to import configuration files, relative to this
# directory. For example, you can emulate configuration per environment
# by uncommenting the line below and defining dev.exs, test.exs and such.
# Configuration from the imported file will override the ones defined
# here (which is why it is important to import them last).
#
if File.exists?("#{File.cwd!()}/config/#{Mix.env()}.exs") do
  import_config "#{Mix.env()}.exs"
end
