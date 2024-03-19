defmodule Cleaner.Application do
  @moduledoc false

  use Application

  @impl Application
  def start(_type, _args) do
    token = Application.fetch_env!(:cleaner, Cleaner.Bot)[:telegram_token]

    children = [
      ExGram,
      {Cleaner.Bot, [method: :polling, token: token]}
    ]

    opts = [strategy: :one_for_one, name: Cleaner.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
