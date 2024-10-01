defmodule Cleaner.User.SpendedMoney do
  @moduledoc false
  use Ecto.Schema

  alias Cleaner.Repo
  alias Cleaner.User

  @type t :: %__MODULE__{}

  schema "users_spended_money" do
    belongs_to :user, User

    field :model, :string
    field :units, :integer

    timestamps(type: :utc_datetime)
  end

  def insert(user, model, units) do
    Repo.insert(%__MODULE__{user_id: user.id, model: model, units: units})
  end
end
