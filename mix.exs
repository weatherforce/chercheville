defmodule ChercheVille.Mixfile do
  use Mix.Project
  @repo_url "https://github.com/weatherforce/chercheville"

  def project do
    [
      app: :chercheville,
      description: "Service allowing to search cities based on data from GeoNames",
      version: "0.2",
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
      {:ecto, "~> 2.0"},
      {:postgrex, "~> 0.11"},
      {:httpotion, "~> 3.0"},
      {:csv, "~> 2.0.0"},
      {:geo_postgis, "~> 1.0"},
      {:excoveralls, "~> 0.8", only: :test},
      {:mox, "~> 0.3", only: :test},
      {:credo, "~> 0.3", only: [:dev, :test]},
      {:earmark, "~> 0.1", only: :dev},
      {:ex_doc, "~> 0.11", only: :dev}
    ]
  end
end
