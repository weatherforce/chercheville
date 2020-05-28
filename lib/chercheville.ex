defmodule ChercheVille do
  @moduledoc """
  ChercheVille is an Elixir service allowing to search cities based on data
  from [GeoNames](http://www.geonames.org/).

  ## Running with Docker

  We provide a Docker image and a `docker-compose.yml` file so you may quickly
  try this app by cloning [the repository](https://github.com/weatherforce/chercheville) and typing:

      $ docker-compose up

  The service should be availble at http://localhost:5000/

  Then to import data into the database you have to call a couple of Elixir functions, providing them a list of  [country codes](https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2) as argument.

  For example, to download the data for France, Belgium and Spain:

      $ docker exec -ti chercheville_app_1 ./bin/chercheville rpc 'ChercheVille.SeedData.fetch_data(["FR", "BE", "ES"])'

  Then to import the data you've downloaded into the database:

      $ docker exec -ti chercheville_app_1 ./bin/chercheville rpc 'ChercheVille.SeedData.import_data(["FR", "BE", "ES"])'

  ## Development installation

  ### Preparing the database

  ChercheVille requires PostgreSQL with the PostGIS extension installed.

  Configure database access in `config/config.exs`:

      config :chercheville, ChercheVille.Repo,
        adapter: Ecto.Adapters.Postgres,
        types: ChercheVille.PostgresTypes,
        database: "cities",
        username: "my_username",
        password: "my_password",
        hostname: "localhost"
      config :chercheville, ecto_repos: [ChercheVille.Repo]

  Update your database schema. This will add a table named `cities`:

      $ mix ecto.migrate

  A couple of mix tasks are available to populate the database. Each task takes
  a list of [country codes](https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2)
  as arguments.

  ### Importing data

  To fetch data files from geonames.org and store them locally:

      $ mix chercheville.fetch_data FR BE ES

  To load data from those files into our database:

      $ mix chercheville.import_data FR BE ES

  ### Starting web service

  Start the web server:

      mix run --no-halt

  Then visiting the http://localhost:4000 should show a list of available endpoints.

  ### Calling Elixir functions directly

  Two search functions are available. Textual search with `ChercheVille.Search.text/1`
  and spatial search with `ChercheVille.Search.coordinates/2`.

  Note that you can start the application with an interactive shell using:

      iex -S mix run --no-halt

  #### Textual search example

      ChercheVille.Search.text("toulouse")

  #### Spatial search example

      ChercheVille.Search.coordinates(43.6, 1.44)

  ### Running tests

  In order to run tests you'll need to create the `cities_test` database with the same extensions as the dev database (see [Preparing the database](#module-preparing-the-database)) and run the migrations in the `test` environment:

      $ MIX_ENV=test mix ecto.migrate
      $ mix test

  ### Building the Docker image

  You should be able to build the Docker image like this:

      $ docker build -t chercheville .

  This Docker packaging has been largely inspired by these articles, which you may want to read for background info:
  - [Build Docker Images From An Elixir Project, Why and How](https://medium.com/@qhwa_85848/build-docker-images-from-an-elixir-project-why-and-how-78e19468210)
  - [Deploy a Phoenix app with Docker stack](https://dev.to/ilsanto/deploy-a-phoenix-app-with-docker-stack-1j9c)
  """
end
