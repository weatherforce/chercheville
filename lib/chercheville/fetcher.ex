defmodule ChercheVille.Fetcher do
  @callback start() :: :ok
  @callback get(url :: String.t) :: HTTPotion.Response.t
end
