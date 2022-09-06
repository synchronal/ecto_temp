# Data Migrations

Database data migrations face at least two primary problems with regard to testing: database schemas
will change in the future; application modules will change in the future. Tests that rely on either
face a high likelihood of failing.

`Ecto` provides a mechanism for overriding the database table used by a query, via `Ecto.put_meta/2`
with the `:source` attribute, or via `{table, Schema}` when making queries.

## Example Data Migration

Imagine a data migration that takes a bunch of things, modifies one or more fields, and creates
other related things.

This data migration can define its own schema modules, representing the schema at the time of
migration. At any place a database interaction occurs, the table name for each entity must be
specified. To ensure that this is the case, the schemas define their tables as
`replace_me_at_runtime`, so that code that forgets to override it will blow up.

```elixir
defmodule Core.DataMigrations.MyMigration do
  import Ecto.Query

  defmodule Thing do
    use Ecto.Schema
    import Ecto.Changeset

    schema "replace_me_at_runtime" do
      field :data, :string
      timestamps()
    end

    @doc """
    Note that when constructing a query, `{table_name, Thing}` is used
    in place of `Thing`. This overrides the database table used by the
    query.
    """
    def all(table_name),
      do: from(things in {table_name, Thing})

    @doc """
    When modifying data, `Ecto.put_meta/2` is utilized to enfore the
    table name.
    """
    def update_changeset(thing, table_name) do
      thing
      |> Ecto.put_meta(source: table_name)
      |> change(data: thing.data <> "-ish")
    end
  end

  defmodule OtherThing do
    use Ecto.Schema
    import Ecto.Changeset

    schema "replace_me_at_runtime" do
      field :thing_id, :bigint
      timestamps()
    end

    def insert_changeset(thing, table_name) do
      %OtherThing{}
      |> Ecto.put_meta(source: table_name)
      |> change(thing_id: thing.id)
    end
  end

  @doc """
  Table names are injected by the tests, but default to the real tables used by
  the application.
  """
  def run(things_table \\ "things", other_things_table \\ "other_things") do
    Core.Repo.transaction(fn ->
      Thing.all(things_table)
      |> Repo.stream()
      |> Stream.map(&Thing.update_changeset(&1, things_table))
      |> Stream.map(&update_thing/1)
      |> Stream.map(&OtherThing.insert_changset(&1, other_things_table))
      |> Stream.map(&insert_other_thing/1)
      |> Stream.run()
    end, timeout: 60_000)
  end

  def update_thing(thing_changeset),
    do: thing_changeset |> Core.Repo.update!()

  def insert_other_thing(other_thing_changeset),
    do: other_thing_changeset |> Core.Repo.insert!()
end
```

## Example Test

The test can rely on the schemas defined by the migration, and inject temporary tables at runtime:

```elixir
defmodule Core.DataMigrations.MyMigrationTest do
  use Test.DataCase, async: true
  use EctoTemp, repo: Core.Repo

  alias Core.DataMigrations.MyMigration, as: Migration
  require EctoTemp.Factory

  deftemptable :temp_things do
    column :data, :string, null: false
    deftimestamps()
  end

  deftemptable :temp_other_things do
    column :thing_id, :integer, null: false
    deftimestamps()
  end

  setup do
    create_temp_tables()
    :ok
  end

  describe "run" do
    test "does stuff" do
      Factory.insert(:temp_things, data: "stuff")
      assert {"temp_other_things", Migration.OtherThing} |> Core.Repo.all() == []

      # inject tables
      Migration.run("temp_things", "temp_other_things")

      [thing] = {"temp_things", Migration.Thing} |> Core.Repo.all()
      assert thing.data == "stuff-ish"

      assert [other_thing] =
          {"temp_other_things", Migration.OtherThing} |> Core.Repo.all()

      assert other_thing.thing_id == thing.id
    end
  end
end
```
