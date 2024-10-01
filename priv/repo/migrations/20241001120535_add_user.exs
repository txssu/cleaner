defmodule Cleaner.Repo.Migrations.AddUser do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :telegram_id, :bigint, null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:users, [:telegram_id])

    create table(:users_spended_money) do
      add :model, :string, null: false
      add :units, :integer, null: false
      add :user_id, references(:users), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:users_spended_money, [:user_id])
  end
end
