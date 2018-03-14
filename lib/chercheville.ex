defmodule ChercheVille do
  @moduledoc """
  ChercheVille is an Elixir service allowing to search cities based on data
  from [GeoNames](http://www.geonames.org/). It uses PostgreSQL as its database.

  ## Adding ChercheVille to your project
  

      defp deps do
        [
          # ...
          {:chercheville, "~> 0.1.0"}
        ]
      end

  ## Populating the database

  A couple of mix tasks are available to populate the database. Each task takes
  a list of [country codes](https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2)
  as arguments.

  To fetch data files from geonames.org and store them locally:

      $ mix fetch_data RU US CN

  To load data from those files into our database:

      $ mix load_data RU US CN

  By default, ChercheVille tries to connect to a database named `cities` on localhost
  with user `postgres` and password `postgres`.

  ## Searching for cities.
  
  Two search modes are available. Textual search with `ChercheVille.Search.text/1`
  and spatial search with `ChercheVille.Search.coordinates/1`.

  ### Textual search example

      ChercheVille.Search.text("toulouse")

  ### Spatial search example
  
      ChercheVille.Search.coordinates(43.6, 1.44)
  """
end
