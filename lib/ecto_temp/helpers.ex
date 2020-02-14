defmodule EctoTemp.Helpers do
  @moduledoc false

  def insert_temporary(repo, table_defs, struct, table_name, params) do
    temp_table = table_defs |> Enum.find(fn table -> table.name == table_name end)

    if is_nil(temp_table),
      do: raise(ArgumentError, "EctoTemp tried to insert into #{inspect(table_name)}; no temp table definition found")

    columns = temp_table.columns |> columns_to_assign(params)

    sql =
      cond do
        temp_table.columns == [] ->
          "INSERT INTO #{temp_table.schema_name} DEFAULT VALUES RETURNING NULL"

        columns == [] ->
          "INSERT INTO #{temp_table.schema_name} DEFAULT VALUES RETURNING *"

        true ->
          {value_counters, _count} =
            Enum.reduce(columns, {[], 1}, fn _column, {value_strings, column_count} ->
              {value_strings ++ ["$#{column_count}"], column_count + 1}
            end)

          "INSERT INTO #{temp_table.schema_name} (#{Enum.join(columns, ", ")}) VALUES (#{
            Enum.join(value_counters, ", ")
          }) RETURNING *"
      end

    values = columns |> order_values(params)

    Ecto.Adapters.SQL.query!(repo, sql, values)
    |> Map.get(:rows)
    |> List.first()
    |> values_to_struct(temp_table, struct, repo)
  end

  defp order_values(columns, params),
    do: columns |> Enum.reduce([], fn column, accumulator -> accumulator ++ [Keyword.fetch!(params, column)] end)

  defp columns_to_assign(columns, params) do
    keys = params |> Keyword.keys()

    columns
    |> Enum.map(& &1.name)
    |> Enum.filter(fn column -> column in keys end)
  end

  defp values_to_struct([nil], %{primary_key: false}, nil, _repo), do: nil
  defp values_to_struct([id | _], %{primary_key: true}, nil, _repo) when is_integer(id), do: id
  defp values_to_struct(values, _temp_table, nil, _repo), do: values

  defp values_to_struct([id | _], %{primary_key: true, schema_name: schema_name}, struct, repo),
    do: repo.get({schema_name, struct}, id)
end
