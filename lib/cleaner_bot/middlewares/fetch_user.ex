defmodule CleanerBot.Middlewares.FetchUser do
  @moduledoc false
  use ExGram.Middleware
  use Pathex

  alias Cleaner.User

  @spec call(ExGram.Cnt.t(), any()) :: ExGram.Cnt.t()
  def call(%{update: %{message: message}} = context, _options) when not is_nil(message) do
    user_id = Pathex.view!(message, path(:from / :id, :map))

    user = User.get_by_id_or_create(user_id)

    add_extra(context, :internal_user, user)
  end

  def call(context, _options), do: context
end
