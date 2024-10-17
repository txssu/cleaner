defmodule Cleaner.Repo.Migrations.RemoveAiModel do
  use Ecto.Migration

  def change do
    alter table(:chats_configs) do
      remove :ai_model, :string, null: false, default: "gpt-4o-mini"
    end
  end
end
