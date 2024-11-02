import Config

config :cleaner, Cleaner.AIChatsStorage,
  gc_interval: :timer.hours(12),
  max_size: 1_000_000,
  allocated_memory: 1_000_000_000,
  gc_cleanup_min_timeout: :timer.seconds(10),
  gc_cleanup_max_timeout: :timer.minutes(10)

config :cleaner, ecto_repos: [Cleaner.Repo]

config :hammer,
  backend: {Hammer.Backend.ETS, [expiry_ms: 60_000 * 60 * 4, cleanup_interval_ms: 60_000 * 10]}

config :tesla, adapter: {Tesla.Adapter.Hackney, recv_timeout: 30_000}

env_config = "#{config_env()}.exs"

if "config" |> Path.join(env_config) |> File.exists?() do
  import_config env_config
end
