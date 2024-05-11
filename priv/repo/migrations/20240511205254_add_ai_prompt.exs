defmodule Cleaner.Repo.Migrations.AddAiPrompt do
  use Ecto.Migration

  def change do
    alter table(:chats_configs) do
      add :ai_prompt, :text
    end
  end
end
