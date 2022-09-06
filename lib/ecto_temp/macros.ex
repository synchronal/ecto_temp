defmodule EctoTemp.Macros do
  @doc """
  Creates a temporary table that will be rolled back at the end of the
  current test transaction. If the table name is given as `:things`, then
  the actual temporary table will be created as `things`. As this may
  overlap with existing tables, it is recommended to use a `temp` prefix
  of suffix when defining temp tables.

  ## Examples

      deftemptable :person_temp do
        column :thing_id, :integer, null: false
        deftimestamps()
      end

      deftemptable :thing_temp, primary_key: false do
        column :description, :string, null: false
        column :comment, :string
      end

  ## Opts

  | name | type | default | description |
  | `primary_key` | boolean | true | When true, adds an `:id` field of type `:bigserial` |
  """
  @spec deftemptable(table_name :: atom(), opts :: keyword()) :: Macro.t()
  defmacro deftemptable(table_name, opts \\ [], do: block),
    do: create_temporary_table_definition(table_name, opts, block)

  @doc """
  Add a column to a table definition.

  This must be called within a `deftemptable` block, or a CompileError will be raised.

  ## Opts

  | name | type | default | description |
  | `default` | term()  |      | Provides a default value when none is provided. |
  | `null`    | boolean | true | Determines whether null values are allowed in a column. |
  """
  @spec column(name :: atom(), type :: atom(), opts :: keyword()) :: Macro.t()
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
  @spec deftimestamps() :: Macro.t()
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

  @spec create_temp_tables() :: Macro.t()
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
        schema_name: "#{unquote(table_name)}",
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
