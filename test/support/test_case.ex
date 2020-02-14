defmodule EctoTemp.TestCase do
  @moduledoc false

  use ExUnit.CaseTemplate

  using do
    quote do
      import EctoTemp.Extra.Assertions
      import EctoTemp.TestCase

      alias EctoTemp.Test.Repo
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(EctoTemp.Test.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(EctoTemp.Test.Repo, {:shared, self()})
    end

    :ok
  end

  def query!(sql) do
    Ecto.Adapters.SQL.query!(EctoTemp.Test.Repo, sql)
  end
end
