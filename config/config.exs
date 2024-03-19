import Config

config :cleaner, ecto_repos: [Cleaner.Repo]

config :cleaner, Oban,
  repo: Cleaner.Repo,
  queues: [default: 10]

env = config_env() |> Atom.to_string() |> String.upcase()

if config_env() != :test do
  config :cleaner, :secret_vault, default: [password: System.fetch_env!("#{env}_KEY")]
end

env_config = "#{config_env()}.exs"

if "config" |> Path.join(env_config) |> File.exists?() do
  import_config env_config
end
