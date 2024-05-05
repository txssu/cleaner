import Config

config :cleaner, Cleaner.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "cleaner_dev",
  show_sensitive_data_on_connection_error: true,
  pool_size: 10

config :cleaner, Cleaner.AI.OpenAIClient,
  api_url: System.fetch_env!("OPENAI_URL"),
  api_key: System.fetch_env!("OPENAI_KEY")
