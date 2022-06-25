# EctoTemp

EctoTemp provides macros and helper functions for creating and utilizing temporary tables in
Postgres. Among other use cases, this library can be utilized to test data migrations (where the
underying table may change over time) or ecto type extensions in isolation, where no one persistent
table exist.

The temporary tables created by this library are transaction local, using `ON COMMIT DROP`. The
[PostgreSQL documentation](https://www.postgresql.org/docs/current/sql-createtable.html) on creating
tables describes this setting as follows:

> The temporary table will be dropped at the end of the current transaction block. When used on a
> partitioned table, this action drops its partitions and when used on tables with inheritance
> children, it drops the dependent children.

For use in `ExUnit`, this means that any temporary tables created in the context of the
`Ecto.Adapters.SQL.Sandbox` are scoped to the test's database connection, and are deleted at the end
of each test.

## Usage

After adding `:ecto_temp` to a project's Mix dependencies, a test can `use EctoTemp, repo:
<My.Repo>`. Temporary tables are defined with `EctoTemp.Macros.deftemptable/3` and
`EctoTemp.Macros.column/2`.

Temp tables are actually created in the database with `EctoTemp.Macros.create_temp_tables/0`.

```elixir
defmodule MyTest do
  use Test.DataCase, async: true
  use EctoTemp, repo: MyProject.Repo

  deftemptable :things do
    column :data, :string, null: false
    column :data_with_default, :string, default: "default value"
    deftimestamps()
  end

  setup do
    create_temp_tables()
    :ok
  end
end
```

In tests, `EctoTemp.Factory.insert/3` can be used to insert data into a temporary table. As a macro,
it must be used via `import` or `require`.

```elixir
defmodule MyTest do
  # ...

  require EctoTemp.Factory

  test "inserts data into a temp table" do
    Factory.insert(:things, data: "stuff")
  end
end
```

An example of a real project using `EctoTemp` to test an `Ecto.Type` extensions can be found in the
[ecto_date_time_range](https://github.com/synchronal/ecto_date_time_range/blob/91b52a634799431ee16f5cdc524850198561866a/test/ecto/utc_date_time_range_test.exs)
project.
