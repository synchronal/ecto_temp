defmodule EctoTemp.Table do
  @moduledoc false

  defstruct name: nil, primary_key: true, schema_name: nil, columns: []

  def columns(columns) do
    columns
    |> Enum.reverse()
    |> Enum.join(",\n    ")
  end
end
