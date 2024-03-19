import Config

config :cleaner, Cleaner.Bot, telegram_token: System.fetch_env!("TELEGRAM_TOKEN")

if config_env() == :prod do
  config :cleaner, Cleaner.Repo,
    url: "ecto://postgres:postgres@database/cleaner_prod",
    pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10")
end
