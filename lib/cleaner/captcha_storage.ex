defmodule Cleaner.CaptchaStorage do
  @moduledoc false
  alias Cleaner.CaptchaStorage
  alias Cleaner.UserCaptcha

  @type key :: {integer(), integer()}

  @spec create(Cleaner.UserCaptcha.t()) :: Supervisor.on_start_child()
  def create(%UserCaptcha{} = user_capcha) do
    CaptchaStorage.DynamicSupervisor.start_child(user_capcha)
  end

  @spec check(integer(), integer(), integer(), String.t()) :: :ok
  def check(chat_id, user_id, message_id, text) do
    case CaptchaStorage.Registry.lookup({chat_id, user_id}) do
      [] -> nil
      [{pid, _value}] -> CaptchaStorage.Item.check(pid, message_id, text)
    end

    :ok
  end
end
