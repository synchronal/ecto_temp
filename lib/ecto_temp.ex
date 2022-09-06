defmodule EctoTemp do
  @moduledoc """
  `EctoTemp` is `use`'d to set up a module for managing temp tables. Once set up, macros such as
  `EctoTemp.Macros.deftemptable/3`, `EctoTemp.Macros.column/3`, and macros in `EctoTemp.Factory`
  may be used.

  ## Examples

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

    deftemptable :other_things, primary_key: false do
      column :id, :uuid, null: false
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
  """

  @doc """
  Imports EctoTemp into a module.

  ## Options

    * `:repo` - required - the module defining your Ecto.Repo callbacks.

  ## Example

  ```elixir
  defmodule MyModule do
    use EctoTemp, repo: MyProject.Repo
  end
  ```
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
