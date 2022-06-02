import Config

if config_env() == :test do
  config :ecto_temp, EctoTemp.Test.Repo,
    username: "postgres",
    password: "postgres",
    hostname: "localhost",
    database: "ecto_temp_test",
    pool: Ecto.Adapters.SQL.Sandbox,
    pool_size: 10
end
