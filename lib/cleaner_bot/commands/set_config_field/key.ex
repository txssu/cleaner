defmodule CleanerBot.Commands.SetConfigField.Key do
  @moduledoc false

  defstruct ~w[name short_name doc]a

  @type t :: %__MODULE__{}

  @spec same_atom_key(t(), atom()) :: boolean()
  def same_atom_key(%__MODULE__{short_name: nil, name: atom_key}, atom_key), do: true
  def same_atom_key(%__MODULE__{short_name: atom_key}, atom_key), do: true
  def same_atom_key(_key, _atom_key), do: false
end
