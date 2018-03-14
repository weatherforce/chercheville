defmodule Mix.Tasks.Chercheville.FetchData do
  @moduledoc """
  Mix task for fetching data files from geonames.
  """
  use Mix.Task

  @shortdoc "Fetch data files from geonames.org"
  def run(country_codes), do: ChercheVille.SeedData.fetch_data(country_codes)
end
