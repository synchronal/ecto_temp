defmodule EctoTemp do
  @moduledoc """
  Provides `deftemptable/2` and `deftemptable/3` macros, and helper functions, for using Postgres temporary tables.

  ## Examples

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
  """

  @doc """
  Imports EctoTemp into a module.

  ## Options

    * `:repo` - required - the module defining your Ecto.Repo callbacks.

  """
  defmacro __using__(opts) do
    quote bind_quoted: [opts: opts] do
      Module.put_attribute(__MODULE__, :ecto_temporary_tables, [])
      @before_compile EctoTemp.Callbacks

      repo =
        Keyword.fetch(opts, :repo)
        |> case do
          :error -> raise ArgumentError, "missing :repo option on use EctoTemp"
          {:ok, repo} -> repo
        end

      @repo repo

      import EctoTemp.Macros
    end
  end
end
