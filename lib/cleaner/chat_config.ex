defmodule Cleaner.ChatConfig do
  @moduledoc false
  use Ecto.Schema

  import Ecto.Changeset

  alias Cleaner.Repo

  @type t :: %__MODULE__{
          chat_id: integer(),
          delete_delay_in_seconds: integer()
        }

  schema "chats_configs" do
    field :chat_id, :integer
    field :delete_delay_in_seconds, :integer, default: 8

    timestamps(type: :utc_datetime)
  end

  @spec changeset(t(), map()) :: Ecto.Changeset.t()
  def changeset(chat_config, attrs) do
    chat_config
    |> cast(attrs, [:delete_delay_in_seconds])
    |> validate_number(:delete_delay_in_seconds, greater_than: 3)
  end

  @spec get_by_id_or_new(integer()) :: t()
  def get_by_id_or_new(chat_id) do
    case Repo.get_by(__MODULE__, chat_id: chat_id) do
      %__MODULE__{} = config -> config
      nil -> %__MODULE__{chat_id: chat_id}
    end
  end

  @spec save(t(), map()) :: {:ok, t()} | {:error, Ecto.Changeset.t()}
  def save(chat_config, attrs) do
    chat_config
    |> changeset(attrs)
    |> Repo.insert_or_update()
  end
end
