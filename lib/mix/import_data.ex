defmodule Mix.Tasks.Chercheville.ImportData do
  @moduledoc """
  Mix task for importing data from geonames files into our database.
  """
  use Mix.Task

  @shortdoc """
  Import data files from geonames.org into the database.

  Files structure:
    http://download.geonames.org/export/dump/readme.txt
  Codes reference:
    http://www.geonames.org/export/codes.html
  """
  def run(country_codes), do: ChercheVille.SeedData.import_data(country_codes)
end
