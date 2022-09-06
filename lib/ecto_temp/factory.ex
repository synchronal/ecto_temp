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
  @spec insert(atom()) :: Macro.t()
  @spec insert(atom(), keyword()) :: Macro.t()
  @spec insert(struct(), atom(), keyword()) :: Macro.t()
  defmacro insert(struct_or_table, table_or_params \\ nil, params \\ []) do
    quote bind_quoted: [struct_or_table: struct_or_table, table_or_params: table_or_params, params: params] do
      cond do
        is_atom(struct_or_table) and is_nil(table_or_params) and is_list(params) ->
          EctoTemp.Helpers.insert_temporary(
            @repo,
            @ecto_temporary_tables,
            nil,
            struct_or_table,
            params
          )

        is_atom(struct_or_table) and is_atom(table_or_params) and is_list(params) ->
          EctoTemp.Helpers.insert_temporary(
            @repo,
            @ecto_temporary_tables,
            struct_or_table,
            table_or_params,
            params
          )

        is_atom(struct_or_table) and is_list(table_or_params) ->
          EctoTemp.Helpers.insert_temporary(
            @repo,
            @ecto_temporary_tables,
            nil,
            struct_or_table,
            table_or_params
          )
      end
    end
  end
end
