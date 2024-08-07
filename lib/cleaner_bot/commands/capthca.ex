defmodule CleanerBot.Commands.Capthca do
  @moduledoc false

  @spec call(context, ExGram.Model.User.t()) :: context
        when context: ExGram.Cnt.t()
  def call(context, %ExGram.Model.User{} = new_member) do
    chat_id = context.update.message.chat.id

    mention = "[#{new_member.first_name}](tg://user?id=#{new_member.id})"
    {answer, capthca_text} = generate_capthca()

    text = """
    #{mention}, у тебя ровно одна минута, чтобы решить капчу:
    #{capthca_text}

    Если ты отправишь что\\-то кроме ответа на капчу, я кикну тебя из чата\\.
    """

    ExGram.send_message!(chat_id, text, parse_mode: "MarkdownV2", bot: CleanerBot.Dispatcher)

    user_capthca = %Cleaner.UserCapthca{
      chat_id: chat_id,
      user_id: new_member.id,
      answer: answer
    }

    Cleaner.CapthcaStorage.create(user_capthca)

    context
  end

  @spec check(ExGram.Model.User.t(), ExGram.Model.Message.t(), context) :: context
        when context: ExGram.Cnt.t()
  def check(%ExGram.Model.User{} = user, %ExGram.Model.Message{} = message, context) do
    chat_id = context.update.message.chat.id
    Cleaner.CapthcaStorage.check(chat_id, user.id, message.text)

    context
  end

  defp generate_capthca do
    left = Enum.random(1..9)
    right = Enum.random(1..9)
    answer = to_string(left + right)

    {answer, "#{left} \\+ #{right} \\= ?"}
  end
end
