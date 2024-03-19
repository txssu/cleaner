defmodule Cleaner.Repo do
  use Ecto.Repo,
    otp_app: :cleaner,
    adapter: Ecto.Adapters.Postgres
end
