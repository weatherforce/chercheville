defmodule Mix.Tasks.ImportData do
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
