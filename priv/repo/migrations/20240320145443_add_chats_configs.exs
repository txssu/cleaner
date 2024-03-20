defmodule Cleaner.Repo.Migrations.AddChatsConfigs do
  use Ecto.Migration

  def change do
    create table(:chats_configs) do
      add :chat_id, :bigint, null: false
      add :delete_delay_in_seconds, :integer, null: false, default: 5

      timestamps(type: :utc_datetime)
    end

    create unique_index(:chats_configs, [:chat_id])
  end
end
