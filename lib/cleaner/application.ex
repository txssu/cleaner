defmodule Cleaner.Application do
  @moduledoc false

  use Application

  @app :cleaner

  @impl Application
  def start(_type, _args) do
    {:ok, _} = EctoBootMigration.migrate(@app)

    token = Application.fetch_env!(@app, CleanerBot.Dispatcher)[:telegram_token]

    children = [
      Cleaner.Scheduler,
      Cleaner.Repo,
      ExGram,
      {CleanerBot.Dispatcher, [method: :polling, token: token]},
      Cleaner.DelayMessageRemover.ListsSupervisor,
      {Registry, name: Cleaner.DelayMessageRemover.ListsRegistry, keys: :unique}
    ]

    opts = [strategy: :one_for_one, name: Cleaner.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
