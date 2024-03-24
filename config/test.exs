import Config

config :cleaner, Cleaner.Repo,
  username: "postgres",
  password: "postgres",
  hostname: System.get_env("POSTGRES_HOST", "localhost"),
  database: "cleaner_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: System.schedulers_online() * 2

config :logger, level: :warning
