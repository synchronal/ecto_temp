defmodule EctoTemp.Column do
  @moduledoc false

  @enforce_keys [:name, :type]
  defstruct name: nil, type: nil, null: true, default: nil

  def type(:decimal), do: "numeric"
  def type(:float), do: "double precision"
  def type(:naive_datetime), do: "timestamp without time zone"
  def type(:string), do: "varchar(255)"
  def type(:utc_datetime), do: "timestamp without time zone"
  def type(column_type), do: column_type

  defimpl String.Chars do
    def to_string(%EctoTemp.Column{} = column),
      do: "#{column.name} #{type(column)}#{default(column)}#{null(column)}"

    defp default(%{default: nil}), do: ""
    defp default(%{default: "NOW()"}), do: " DEFAULT NOW()"
    defp default(%{default: "now()"}), do: " DEFAULT NOW()"
    defp default(%{default: default}), do: " DEFAULT '#{default}'"
    defp null(%{null: true}), do: ""
    defp null(%{null: false}), do: " NOT NULL"
    defp type(column), do: EctoTemp.Column.type(column.type)
  end
end
