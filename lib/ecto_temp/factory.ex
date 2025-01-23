defmodule EctoTemp.Factory do
  @doc """
  Inserts values into a temporary table.

  ## Params:

    * struct (optional) - a struct defined the schema used by the data migration.
    * table_name
    * attrs (optional) - a keyword list of attributes to insert

  ## Notes:

    * If not given a struct, and the temporary table has a primary key, then we return the `id` of the inserted row.
    * If given a struct, and the temporary table has a primary key, then we do a `Repo.get` using the `id` of the
      inserted row, and return the result as a struct.
    * If the temporary table has no primary key, then we return the list of values returned by postgres. This list
      is probably ordered by the order in which the columns are defined on the temp table???

  ## Examples

      import EctoTemp.Factory

      insert(:thing_with_no_primary_key) == []
      insert(:thing_with_no_primary_key, some_thing: "hi") == ["hi"]
      insert(:thing_with_primary_key) == 1
      insert(:thing_with_primary_key, some_thing: "hi") == 2
      %MyDataMigration.Cycle{id: 1} = insert(MyDataMigration.Cycle, :cycles, started_at: ~N[2020-02-03 00:00:00])

  """
  defmacro insert(table) do
    quote bind_quoted: [table: table] do
      EctoTemp.Helpers.insert_temporary(
        @repo,
        @ecto_temporary_tables,
        nil,
        table,
        []
      )
    end
  end

  defmacro insert({:__aliases__, _, [_ | _]} = module, table) do
    quote bind_quoted: [module: module, table: table] do
      EctoTemp.Helpers.insert_temporary(
        @repo,
        @ecto_temporary_tables,
        module,
        table,
        []
      )
    end
  end

  defmacro insert(table, params) do
    quote bind_quoted: [table: table, params: params] do
      EctoTemp.Helpers.insert_temporary(
        @repo,
        @ecto_temporary_tables,
        nil,
        table,
        params
      )
    end
  end

  defmacro insert(module, table, params) do
    quote bind_quoted: [module: module, table: table, params: params] do
      EctoTemp.Helpers.insert_temporary(
        @repo,
        @ecto_temporary_tables,
        module,
        table,
        params
      )
    end
  end

  @doc """
  Generates a UUID that may be inserted directly into a `:uuid` field. Use this in preference of
  `Ecto.UUID.generate/0` or `Ecto.UUID.bingenerate/0`, as those will not dump their string values
  to the binary format expected by postgres.
  """
  @spec uuid() :: binary()
  def uuid do
    {:ok, uuid} = Ecto.UUID.dump(Ecto.UUID.generate())
    uuid
  end
end
