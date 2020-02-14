defmodule EctoTemp.Test.Repo do
  use Ecto.Repo, otp_app: :ecto, adapter: Ecto.Adapters.Postgres

  def log(_cmd), do: nil
end
