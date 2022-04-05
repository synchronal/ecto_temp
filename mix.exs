defmodule EctoTemp.MixProject do
  use Mix.Project

  def project do
    [
      app: :ecto_temp,
      deps: deps(),
      description: description(),
      elixir: "~> 1.10",
      elixirc_paths: elixirc_paths(Mix.env()),
      package: package(),
      source_url: "https://github.com/synchronal/ecto_temp",
      start_permanent: Mix.env() == :prod,
      version: "0.1.0"
    ]
  end

  def application, do: [extra_applications: [:logger]]

  defp deps,
    do: [
      {:ecto, ">= 3.0.0", only: :test},
      {:ecto_sql, "> 3.0.0", only: :test},
      {:postgrex, ">= 0.0.0", only: :test},
      {:ex_doc, "~> 0.19", only: [:docs, :dev]}
    ]

  defp description(),
    do: "Tools for using Postgres temporary tables with Ecto"

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp package(),
    do: [
      licenses: ["MIT"],
      maintainers: ["Eric Saxby"],
      links: %{github: "https://github.com/synchronal/ecto_temp"}
    ]
end
