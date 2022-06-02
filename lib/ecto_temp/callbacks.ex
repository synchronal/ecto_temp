defmodule EctoTemp.Callbacks do
  @moduledoc false
  defmacro __before_compile__(_env) do
    quote do
      def __ecto_temp_tables__, do: @ecto_temporary_tables
    end
  end
end
