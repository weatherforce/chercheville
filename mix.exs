defmodule ChercheVille.Mixfile do
  use Mix.Project

  def project do
    [
      app: :chercheville,
      version: "0.1.0",
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {ChercheVille.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ecto, "~> 2.0"},
      {:postgrex, "~> 0.11"},
      {:httpotion, "~> 3.0"},
      {:csv, "~> 2.0.0"},
      {:geo_postgis, "~> 1.0"}
    ]
  end
end
