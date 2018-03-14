defmodule ChercheVille.Fetcher do
  @moduledoc """
  Behaviour of a module for fetching from a url. Used for mocking HTTP requests.
  """
  @callback start() :: :ok
  @callback get(url :: String.t()) :: HTTPotion.Response.t()
end
