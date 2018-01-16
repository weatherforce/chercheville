defmodule CityFTS.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    import Supervisor.Spec
    # List all child processes to be supervised
    children = [
      CityFTS.Repo, CityFTS.Search
      # Starts a worker by calling: CityFTS.Worker.start_link(arg)
      # {CityFTS.Worker, arg},
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: CityFTS.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
