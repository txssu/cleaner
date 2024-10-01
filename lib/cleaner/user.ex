defmodule Cleaner.User do
  @moduledoc false
  use Ecto.Schema

  alias Cleaner.Repo

  @type t :: %__MODULE__{}

  schema "users" do
    field :telegram_id, :integer

    timestamps(type: :utc_datetime)
  end

  @spec get_by_id_or_create(integer()) :: t()
  def get_by_id_or_create(telegram_id) do
    case Repo.get_by(__MODULE__, telegram_id: telegram_id) do
      %__MODULE__{} = user -> user
      nil -> Repo.insert!(%__MODULE__{telegram_id: telegram_id})
    end
  end
end
