defmodule EctoTemp.MixProject do
  use Mix.Project

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

  def application, do: [extra_applications: [:logger]]

  defp deps,
    do: [
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.1", only: [:dev, :test], runtime: false},
      {:ecto, ">= 3.0.0"},
      {:ecto_sql, "> 3.0.0"},
      {:ex_doc, "~> 0.28", only: [:docs, :dev]},
      {:mix_audit, "~> 1.0", only: :dev, runtime: false},
      {:postgrex, ">= 0.0.0", only: :test}
    ]

  defp description(),
    do: "Tools for using Postgres temporary tables with Ecto"

  defp dialyzer do
    [
      plt_add_apps: [:ex_unit, :mix],
      plt_add_deps: :app_tree,
      plt_file: {:no_warn, "priv/plts/dialyzer.plt"}
    ]
  end

  defp docs do
    [
      main: "EctoTemp",
      extras: ["README.md", "LICENSE.md"]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp package(),
    do: [
      files: ~w[
        .formatter.exs
        README.*
        VERSION
        lib
        LICENSE.*
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
