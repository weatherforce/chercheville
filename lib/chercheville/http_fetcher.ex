defmodule ChercheVille.HTTPFetcher do
  @behaviour ChercheVille.Fetcher
  def start do
    HTTPotion.start()
  end
  def get(url) do
    HTTPotion.get(url)
  end
end
