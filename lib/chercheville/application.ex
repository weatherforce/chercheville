defmodule ChercheVille.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    opts = [strategy: :one_for_one, name: ChercheVille.Supervisor]
    Supervisor.start_link([ChercheVille.Repo], opts)
  end
end
