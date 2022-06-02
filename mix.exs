defmodule EctoTemp.MixProject do
  use Mix.Project

  def project do
    [
      app: :ecto_temp,
      deps: deps(),
      description: description(),
      dialyzer: dialyzer(),
      elixir: "~> 1.10",
      elixirc_paths: elixirc_paths(Mix.env()),
      package: package(),
      preferred_cli_env: [credo: :test, dialyzer: :test],
      source_url: "https://github.com/synchronal/ecto_temp",
      start_permanent: Mix.env() == :prod,
      version: "0.1.0"
    ]
  end

  def application, do: [extra_applications: [:logger]]

  defp deps,
    do: [
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.1", only: [:dev, :test], runtime: false},
      {:ecto, ">= 3.0.0", only: :test},
      {:ecto_sql, "> 3.0.0", only: :test},
      {:ex_doc, "~> 0.19", only: [:docs, :dev]},
      {:mix_audit, "~> 1.0", only: :dev, runtime: false},
      {:postgrex, ">= 0.0.0", only: :test}
    ]

  defp description(),
    do: "Tools for using Postgres temporary tables with Ecto"

  defp dialyzer do
    [
      plt_add_apps: [:ex_unit, :mix],
      plt_add_deps: :app_tree
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp package(),
    do: [
      licenses: ["Apache 2.0"],
      maintainers: ["Eric Saxby"],
      links: %{github: "https://github.com/synchronal/ecto_temp"}
    ]
end
