Logger.configure(level: :info)
ExUnit.start()

alias EctoTemp.Test.Repo

Application.put_env(:ecto, Repo,
  url: "ecto://postgres@localhost/ecto_temp_test",
  pool: Ecto.Adapters.SQL.Sandbox
)

# Load up the repository, start it, and run migrations
_ = Ecto.Adapters.Postgres.storage_down(Repo.config())

Ecto.Adapters.Postgres.storage_up(Repo.config())
|> case do
  :ok -> :ok
  {:error, :already_up} -> :ok
end

{:ok, _pid} = Repo.start_link()
