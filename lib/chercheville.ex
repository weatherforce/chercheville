defmodule ChercheVille do
  @moduledoc """
  ChercheVille is an Elixir service allowing to search cities based on data
  from [GeoNames](http://www.geonames.org/).

  ## Preparing the database

  ChercheVille requires a PostgreSQL database with these extensions enabled:

      cities=# CREATE EXTENSION postgis;
      cities=# CREATE EXTENSION unaccent;
      cities=# CREATE EXTENSION pg_trgm;

  Configure database access in `config/config.exs`:

      config :chercheville, ChercheVille.Repo,
        adapter: Ecto.Adapters.Postgres,
        types: ChercheVille.PostgresTypes,
        database: "my_db",
        username: "my_username",
        password: "my_password",
        hostname: "localhost"
      config :chercheville, ecto_repos: [ChercheVille.Repo]

  Update your database schema. This will add a table named `cities`:

      $ mix ecto.migrate

  A couple of mix tasks are available to populate the database. Each task takes
  a list of [country codes](https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2)
  as arguments.

  ## Importing data

  To fetch data files from geonames.org and store them locally:

      $ mix chercheville.fetch_data FR BE ES

  To load data from those files into our database:

      $ mix chercheville.import_data FR BE ES

  ## Starting web service

  Start the web server:

      mix run --no-halt

  Then visiting the http://localhost:4000 should show a list of available endpoints.

  ## Calling Elixir functions directly
  
  Two search functions are available. Textual search with `ChercheVille.Search.text/1`
  and spatial search with `ChercheVille.Search.coordinates/2`.

  ### Textual search example

      ChercheVille.Search.text("toulouse")

  ### Spatial search example
  
      ChercheVille.Search.coordinates(43.6, 1.44)
  """
end
