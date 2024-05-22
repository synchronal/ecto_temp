defmodule EctoTemp.MixProject do
  use Mix.Project

  def application, do: [extra_applications: [:logger]]

  def project do
    [
      app: :ecto_temp,
      deps: deps(),
      description: description(),
      dialyzer: dialyzer(),
      docs: docs(),
      elixir: "~> 1.10",
      elixirc_paths: elixirc_paths(Mix.env()),
      package: package(),
      preferred_cli_env: [credo: :test, dialyzer: :test],
      source_url: "https://github.com/synchronal/ecto_temp",
      start_permanent: Mix.env() == :prod,
      version: version()
    ]
  end

  def cli,
    do: [
      preferred_envs: [credo: :test, dialyzer: :test]
    ]

  # # #

  defp deps,
    do: [
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.1", only: [:dev, :test], runtime: false},
      {:ecto, ">= 3.0.0"},
      {:ecto_sql, "> 3.0.0"},
      {:ex_doc, "~> 0.28", only: [:docs, :dev]},
      {:markdown_formatter, "~> 0.4", only: :dev, runtime: false},
      {:mix_audit, "~> 2.0", only: :dev, runtime: false},
      {:postgrex, ">= 0.0.0", only: :test}
    ]

  defp description(),
    do: "Tools for using Postgres temporary tables with Ecto"

  defp dialyzer do
    [
      plt_add_apps: [:ex_unit, :mix],
      plt_add_deps: :app_tree,
      plt_core_path: "_build/plts/#{Mix.env()}",
      plt_local_path: "_build/plts/#{Mix.env()}"
    ]
  end

  defp docs do
    [
      extras: [
        "guides/overview.md",
        "guides/data_migrations.md",
        "CHANGELOG.md",
        "LICENSE.md"
      ],
      main: "overview"
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp package(),
    do: [
      files: ~w[
        .formatter.exs
        CHANGELOG.*
        LICENSE.*
        README.*
        VERSION
        lib
        mix.exs
      ],
      licenses: ["Apache-2.0"],
      maintainers: ["Eric Saxby"],
      links: %{github: "https://github.com/synchronal/ecto_temp"}
    ]

  defp version do
    case Path.expand(Path.join([__ENV__.file, "..", "VERSION"])) |> File.read() do
      {:error, _} -> "0.0.0"
      {:ok, version_number} -> version_number |> String.trim()
    end
  end
end
