import Config
import SecretVault, only: [runtime_secret!: 2]

config :cleaner, Cleaner.Bot, telegram_token: runtime_secret!(:cleaner, "telegram_token")
