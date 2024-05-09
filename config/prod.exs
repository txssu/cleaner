import Config

config :logger, level: :info

config :cleaner, Cleaner.Scheduler,
  jobs: [
    {"0 18 * * *", {Cleaner.Commands.NikitaCounter, :cron, []}}
  ]

config :cleaner, Cleaner.Commands.NikitaCounter,
  chat_id: -1_001_549_164_880,
  user_id: 562_754_575
