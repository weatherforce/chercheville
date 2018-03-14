defmodule ChercheVille.HTTPFetcher do
  @moduledoc """
  Implemention of the `ChercheVille.Fetcher` behaviour that makes actual
  HTTP requests. This is swaped with a mock when running tests.
  """
  @behaviour ChercheVille.Fetcher
  def start do
    HTTPotion.start()
  end

  def get(url) do
    HTTPotion.get(url)
  end
end
