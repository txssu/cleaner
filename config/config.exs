import Config

env = config_env() |> Atom.to_string() |> String.upcase()

if config_env() != :test do
  config :cleaner, :secret_vault, default: [password: System.fetch_env!("#{env}_KEY")]
end
