import Config

config :cleaner, ecto_repos: [Cleaner.Repo]

config :hammer,
  backend: {Hammer.Backend.ETS, [expiry_ms: 60_000 * 60 * 4, cleanup_interval_ms: 60_000 * 10]}

config :tesla, adapter: {Tesla.Adapter.Hackney, recv_timeout: 30_000}

env_config = "#{config_env()}.exs"

if "config" |> Path.join(env_config) |> File.exists?() do
  import_config env_config
end
