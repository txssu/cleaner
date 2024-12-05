defmodule Cleaner.Update do
  @moduledoc false

  use Ecto.Schema

  alias Cleaner.Repo

  @type t :: %__MODULE__{}

  schema "updates" do
    field :update, :map

    timestamps(type: :utc_datetime)
  end

  @spec save(map()) :: {:ok, t()} | {:error, Ecto.Changeset.t()}
  def save(update) do
    Repo.insert(%__MODULE__{update: update})
  end
end
