defmodule ChercheVille.Mixfile do
  use Mix.Project
  @repo_url "https://github.com/weatherforce/chercheville"

  def project do
    [
      app: :chercheville,
      description: "Service allowing to search cities based on data from GeoNames",
      version: "0.2.0",
      elixir: "~> 1.6",
      source_url: @repo_url,
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ],
      docs: [main: "ChercheVille"]
    ]
  end

  def package do
    [
      maintainers: ["Alex Marandon"],
      links: %{
        "GitHub" => @repo_url,
        "WeatherForce" => "http://weatherforce.org"
      },
      licenses: ["MIT"],
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
      {:ecto_sql, "~> 3.4"},
      {:postgrex, ">= 0.0.0"},
      {:httpotion, "~> 3.1"},
      {:csv, "~> 2.3"},
      {:geo_postgis, "~> 3.3"},
      {:plug_cowboy, "~> 2.0"},
      {:excoveralls, "~> 0.12", only: :test},
      {:mox, "~> 0.5", only: :test},
      {:credo, "~> 1.4", only: [:dev, :test]},
      {:earmark, "~> 1.4", only: :dev},
      {:ex_doc, "~> 0.22", only: :dev}
    ]
  end
end
