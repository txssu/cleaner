import Config

config :cleaner, Cleaner.Bot, telegram_token: System.fetch_env!("TELEGRAM_TOKEN")
