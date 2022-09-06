defmodule EctoTemp.ColumnTest do
  use EctoTemp.TestCase

  use EctoTemp, repo: EctoTemp.Test.Repo

  deftemptable :things_temp do
    column :binary_string, :string, null: false
    column :binary_text, :text
    column :number_decimal, :decimal
    column :number_float, :float
    column :number_integer, :integer, default: 0
    column :time_naive, :naive_datetime
    column :time_utc, :utc_datetime
    column :uuid_id, :uuid
    deftimestamps()
  end

  deftemptable :things_with_binary_id_temp, primary_key: false do
    column :id, :uuid, primary_key: true
  end

  describe "column" do
    test "maps ecto types to postgres types" do
      create_temp_tables()

      query!("""
      SELECT column_name, data_type, character_maximum_length, column_default, is_nullable
      FROM information_schema.columns
      WHERE table_name = 'things_temp'
      ORDER BY column_name
      """)
      |> Map.get(:rows)
      |> assert_eq([
        ["binary_string", "character varying", 255, nil, "NO"],
        ["binary_text", "text", nil, nil, "YES"],
        ["id", "bigint", nil, "nextval('things_temp_id_seq'::regclass)", "NO"],
        ["inserted_at", "timestamp without time zone", nil, "now()", "YES"],
        ["number_decimal", "numeric", nil, nil, "YES"],
        ["number_float", "double precision", nil, nil, "YES"],
        ["number_integer", "integer", nil, "0", "YES"],
        ["time_naive", "timestamp without time zone", nil, nil, "YES"],
        ["time_utc", "timestamp without time zone", nil, nil, "YES"],
        ["updated_at", "timestamp without time zone", nil, "now()", "YES"],
        ["uuid_id", "uuid", nil, nil, "YES"]
      ])
    end

    test "allows for uuid primary key" do
      create_temp_tables()

      query!("""
      SELECT column_name, data_type, character_maximum_length, column_default, is_nullable
      FROM information_schema.columns
      WHERE table_name = 'things_with_binary_id_temp'
      ORDER BY column_name
      """)
      |> Map.get(:rows)
      |> assert_eq([
        ["id", "uuid", nil, nil, "YES"]
      ])
    end
  end
end
