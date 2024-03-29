defmodule Cleaner.Repo.Migrations.AddLastHelpMessage do
  use Ecto.Migration

  def change do
    alter table(:chats_configs) do
      add :last_help_message, :string
    end
  end
end
