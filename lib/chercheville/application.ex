defmodule ChercheVille.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      ChercheVille.Repo,
      ChercheVille.Search
      # Starts a worker by calling: ChercheVille.Worker.start_link(arg)
      # {ChercheVille.Worker, arg},
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ChercheVille.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
