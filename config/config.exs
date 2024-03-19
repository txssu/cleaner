import Config

config :cleaner, ecto_repos: [Cleaner.Repo]

config :cleaner, Oban,
  repo: Cleaner.Repo,
  queues: [default: 10]

env_config = "#{config_env()}.exs"

if "config" |> Path.join(env_config) |> File.exists?() do
  import_config env_config
end
