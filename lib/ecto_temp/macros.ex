defmodule EctoTemp.Macros do
  @doc """
  Creates a temporary table that will be rolled back at the end of the
  current test transaction. If the table name is given as `:thing`, then
  the actual temporary table will be created as `thing_temp`.

  ## Examples

      deftemptable :cycles do
        column :athlete_plan_id, :integer, null: false
        deftimestamps()
      end

      deftemptable :scan, primary_key: false do
        column :scan_sha, :string, null: false
        column :comment, :string
      end

  ## Opts

  | name | type | default | description |
  | `primary_key` | boolean | true | When true, adds an `:id` field of type `:bigserial` |
  """
  defmacro deftemptable(table_name, opts \\ [], do: block),
    do: create_temporary_table_definition(table_name, opts, block)

  @doc """
  Add a column to a table definition.

  This must be called within a `deftemptable` block, or a CompileError will be raised.
  """
  defmacro column(name, type, opts \\ []) do
    quote do
      table = Module.get_attribute(__MODULE__, :__temp_table_definition__)

      if is_nil(table),
        do:
          raise(CompileError,
            description: "Expected `column` to be called within a `deftemptable` block",
            file: __ENV__.file,
            line: __ENV__.line
          )

      null = unquote(opts) |> Keyword.get(:null, true)
      default = unquote(opts) |> Keyword.get(:default, nil)
      column = %EctoTemp.Column{name: unquote(name), type: unquote(type), null: null, default: default}

      table = %{table | columns: [column | table.columns]}
      Module.put_attribute(__MODULE__, :__temp_table_definition__, table)
    end
  end

  @doc """
  Adds `inserted_at` and `updated_at` to a table definition.

  This must be called within a `deftemptable` block, or a CompileError will be raised.
  """
  defmacro deftimestamps do
    quote do
      table = Module.get_attribute(__MODULE__, :__temp_table_definition__)

      if is_nil(table),
        do:
          raise(CompileError,
            description: "Expected `deftimestamps` to be called within a `deftemptable` block",
            file: __ENV__.file,
            line: __ENV__.line
          )

      inserted_at = %EctoTemp.Column{name: :inserted_at, type: :utc_datetime, null: true, default: "NOW()"}
      updated_at = %EctoTemp.Column{name: :updated_at, type: :utc_datetime, null: true, default: "NOW()"}

      table = %{table | columns: [inserted_at, updated_at | table.columns]}
      Module.put_attribute(__MODULE__, :__temp_table_definition__, table)
    end
  end

  @doc """
  Runs through previously defined `@ecto_temporary_tables` to insert temporary tables.
  This should be called in a setup block, which needs to be defined **after** all
  `deftemptable` definitions.
  """
  defmacro create_temp_tables do
    quote do
      create_ecto_temporary_tables(@repo, @ecto_temporary_tables)
    end
  end

  @doc false
  def create_ecto_temporary_tables(repo, ecto_temporary_tables),
    do: Enum.each(ecto_temporary_tables, &Ecto.Adapters.SQL.query!(repo, create_temp_table_sql(&1)))

  @doc false
  defp create_temp_table_sql(table),
    do: """
    CREATE TEMPORARY TABLE #{table.schema_name}
      (
        #{EctoTemp.Table.columns(table.columns)}
      )
    ON COMMIT DROP
    """

  defp create_temporary_table_definition(table_name, opts, block) do
    quote do
      table_opts = unquote(opts)
      primary_key = table_opts |> Keyword.get(:primary_key, true)

      columns = if primary_key, do: [%EctoTemp.Column{name: :id, type: :bigserial, null: false}], else: []

      table = %EctoTemp.Table{
        name: unquote(table_name),
        primary_key: primary_key,
        schema_name: "#{unquote(table_name)}_temp",
        columns: columns
      }

      Module.put_attribute(__MODULE__, :__temp_table_definition__, table)

      unquote(block)

      table = Module.get_attribute(__MODULE__, :__temp_table_definition__)
      Module.delete_attribute(__MODULE__, :__temp_table_definition__)

      ecto_temporary_tables = [table | Module.get_attribute(__MODULE__, :ecto_temporary_tables)]

      Module.put_attribute(__MODULE__, :ecto_temporary_tables, ecto_temporary_tables)
    end
  end
end
