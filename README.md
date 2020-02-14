# EctoTemp

EctoTemp is an Ecto extension to support using PostgreSQL temporary tables with Ecto. This can be useful in
situations where permanent tables may not be viable, such as when testing data migrations (where the schema
at the time of test creation will differ over time), or to test modules that extend Ecto, but are not
concernted with a specific schema.

## Installation

Add `ecto_temp` to `mix.exs`. Consider only adding it to the `:test` environment.

```elixir
def deps do
  [
    {:ecto_temp, "~> 0.1.0", only: :test}
  ]
end
```

## Usage

EctoTemp provides several macros which can be included by `use`ing `EctoTemp`.

```elixir
defmodule MyTest do
  use MyProject.DataCase
  use EctoTemp, repo: MyProject.Repo

  require EctoTemp.Factory
  alias EctoTemp.Factory

  deftemptable :things do
    column :data, :string, null: false
    column :data_with_default, :string, default: "default value"
    deftimestamps()
  end

  setup do
    create_temp_tables()
    :ok
  end

  test "insert records" do
    Factory.insert(:things, data: "stuff")
  end
end
```

## Links

  * [Documentation](http://hexdocs.pm/ecto_temp)
  * [License](https://github.com/livinginthepast/ecto_temp/blob/master/LICENSE)