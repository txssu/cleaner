defmodule Cleaner.Repo.Migrations.SaveAllUpdates do
  use Ecto.Migration

  def change do
    create table(:updates) do
      add :update, :jsonb, null: false

      timestamps(type: :utc_datetime)
    end
  end
end
