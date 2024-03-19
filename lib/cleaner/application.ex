defmodule Cleaner.Application do
  @moduledoc false

  use Application

  @impl Application
  def start(_type, _args) do
    token = Application.fetch_env!(:cleaner, Cleaner.Bot)[:telegram_token]

    children = [
      Cleaner.Repo,
      ExGram,
      {Cleaner.Bot, [method: :polling, token: token]},
      {Oban, Application.fetch_env!(:cleaner, Oban)}
    ]

    opts = [strategy: :one_for_one, name: Cleaner.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
