defmodule EctoTempTest do
  use EctoTemp.TestCase

  use EctoTemp, repo: EctoTemp.Test.Repo

  deftemptable :thing_with_id_temp do
  end

  deftemptable :thing_without_id_temp, primary_key: false do
  end

  describe "create_temp_tables" do
    test "creates a temporary table for each deftemptable" do
      assert_event(
        &create_temp_tables/0,
        changes: fn ->
          query!("SELECT table_name FROM information_schema.tables WHERE table_schema LIKE 'pg_temp%';")
          |> Map.get(:num_rows)
        end,
        from: 0,
        to: 2
      )

      query!("""
      SELECT table_name, table_type FROM information_schema.tables
      WHERE table_schema LIKE 'pg_temp%'
      ORDER BY table_name ASC;
      """)
      |> Map.get(:rows)
      |> assert_eq([
        ["thing_with_id_temp", "LOCAL TEMPORARY"],
        ["thing_without_id_temp", "LOCAL TEMPORARY"]
      ])
    end

    test "creates temporary tables with a bigserial id by default" do
      create_temp_tables()

      query!("""
      SELECT column_name, data_type, character_maximum_length, column_default
      FROM information_schema.columns
      WHERE table_name = 'thing_with_id_temp'
      """)
      |> Map.get(:rows)
      |> assert_eq([["id", "bigint", nil, "nextval('thing_with_id_temp_id_seq'::regclass)"]])
    end

    test "creates temporary tables without id when :primary_key is false" do
      create_temp_tables()

      query!("""
      SELECT column_name, data_type, character_maximum_length, column_default
      FROM information_schema.columns
      WHERE table_name = 'thing_without_id_temp'
      """)
      |> Map.get(:rows)
      |> assert_eq([])
    end
  end
end
