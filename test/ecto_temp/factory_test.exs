defmodule EctoTemp.FactoryTest do
  use EctoTemp.TestCase

  use EctoTemp, repo: EctoTemp.Test.Repo
  require EctoTemp.Factory
  alias EctoTemp.Factory

  deftemptable :with_pk_and_columns do
    column :binary_string, :string
    column :binary_text, :text
    column :number_decimal, :decimal
    column :number_float, :float
    column :number_integer, :integer, default: 6
    column :time_naive, :naive_datetime
    column :time_utc, :utc_datetime
    deftimestamps()
  end

  deftemptable :without_pk_no_columns, primary_key: false do
  end

  deftemptable :without_pk_with_columns, primary_key: false do
    column :binary_string, :string
    deftimestamps()
  end

  defmodule Thing do
    use Ecto.Schema

    schema "replace-me" do
      field(:binary_string, :string)
      field(:binary_text, :string)
      field(:number_decimal, :decimal)
      field(:number_float, :float)
      field(:number_integer, :integer, read_after_writes: true)
      field(:time_naive, :naive_datetime)
      field(:time_utc, :utc_datetime)
      timestamps()
    end
  end

  setup do
    create_temp_tables()
    :ok
  end

  describe "insert without attrs" do
    test "raises when given a table that does not exist" do
      assert_raise ArgumentError, "EctoTemp tried to insert into :not_here; no temp table definition found", fn ->
        Factory.insert(:not_here)
      end
    end

    test "inserts a row with no values, returning primary key" do
      id1 = Factory.insert(:with_pk_and_columns)
      id2 = Factory.insert(:with_pk_and_columns)

      assert id2 == id1 + 1
    end

    test "inserts a row with no values, without primary key, returning nil" do
      Factory.insert(:without_pk_no_columns)
      |> assert_eq(nil)
    end

    test "inserts a row with default values, without primary key, returning values" do
      assert [nil, inserted_at, updated_at] = Factory.insert(:without_pk_with_columns)

      inserted_at |> assert_recent()
      updated_at |> assert_recent()
    end

    test "returns the given struct, with id and defaults set" do
      assert %Thing{} = thing = Factory.insert(Thing, :with_pk_and_columns)

      assert is_nil(thing.binary_string)
      assert is_nil(thing.binary_text)
      assert is_nil(thing.number_decimal)
      assert is_nil(thing.number_float)
      assert thing.number_integer == 6
      assert is_nil(thing.time_naive)
      assert is_nil(thing.time_utc)
    end
  end

  describe "insert with attrs" do
    test "inserts a row with values, returning inserted values" do
      [binary_string, inserted_at, updated_at] =
        Factory.insert(:without_pk_with_columns, binary_string: "binary_string")

      binary_string |> assert_eq("binary_string")
      inserted_at |> assert_recent()
      updated_at |> assert_recent()

      assert [
               "binary_string",
               inserted_at,
               updated_at
             ] =
               query!("""
               SELECT *
               FROM without_pk_with_columns
               """)
               |> Map.get(:rows)
               |> List.first()

      inserted_at |> assert_recent()
      updated_at |> assert_recent()
    end

    test "inserts a row with values, returning primary key" do
      Factory.insert(:with_pk_and_columns,
        binary_string: "binary_string",
        binary_text: "binary_text",
        number_decimal: Decimal.new("1.01"),
        number_float: 0.99,
        number_integer: 12,
        time_naive: ~N[2020-02-03 00:00:00],
        time_utc: ~N[2020-02-04 00:00:00]
      )
      |> assert_eq(~r|\d+|)

      assert [
               1,
               "binary_string",
               "binary_text",
               decimal_value,
               0.99,
               12,
               ~N[2020-02-03 00:00:00.000000],
               ~N[2020-02-04 00:00:00.000000],
               inserted_at,
               updated_at
             ] =
               query!("""
               SELECT *
               FROM with_pk_and_columns
               """)
               |> Map.get(:rows)
               |> List.first()

      decimal_value |> assert_eq(Decimal.new("1.01"))
      inserted_at |> assert_recent()
      updated_at |> assert_recent()
    end
  end
end
