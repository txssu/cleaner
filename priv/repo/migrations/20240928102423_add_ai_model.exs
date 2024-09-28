defmodule Cleaner.Repo.Migrations.AddAiModel do
  use Ecto.Migration

  def change do
    alter table(:chats_configs) do
      add :ai_model, :string, null: false, default: "gpt-4o-mini"
    end
  end
end
