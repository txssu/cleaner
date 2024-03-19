defmodule Cleaner.Application do
  @moduledoc false

  use Application

  @app :cleaner

  @impl Application
  def start(_type, _args) do
    {:ok, _} = EctoBootMigration.migrate(@app)

    token = Application.fetch_env!(@app, Cleaner.Bot)[:telegram_token]

    children = [
      Cleaner.Repo,
      ExGram,
      {Cleaner.Bot, [method: :polling, token: token]},
      {Oban, Application.fetch_env!(@app, Oban)}
    ]

    opts = [strategy: :one_for_one, name: Cleaner.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
