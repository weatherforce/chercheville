defmodule ChercheVille.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    web_server =
      {Plug.Cowboy,
       scheme: :http,
       plug: ChercheVille.Web,
       options: [
         port: Application.get_env(:chercheville, :http_port)
       ]}

    children = [ChercheVille.Repo, web_server]

    opts = [strategy: :one_for_one, name: ChercheVille.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
