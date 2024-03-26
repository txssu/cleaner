import Config

config :cleaner, Cleaner.Bot, telegram_token: System.get_env("TELEGRAM_TOKEN")

if config_env() == :prod do
  config :cleaner, Cleaner.Repo,
    url: System.get_env("DATABASE_URL", "ecto://postgres:postgres@database/cleaner_prod"),
    pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10")
end
