defmodule Mix.Tasks.FetchData do
  use Mix.Task

  @shortdoc "Fetch data files from geonames.org"
  def run(country_codes), do: CityFTS.SeedData.fetch_data(country_codes)
end
