defmodule Cleaner.Version do
  @moduledoc false

  @external_resource git_revision_file = ".git/HEAD"

  if File.exists?(git_revision_file) do
    head_contents = File.read!(git_revision_file)

    if String.starts_with?(head_contents, "ref:") do
      ref_path = head_contents |> String.replace("ref:", "") |> String.trim()
      @external_resource ".git/#{ref_path}"
    end
  end

  {version, 0} = System.cmd("git", ["rev-parse", "--short", "HEAD"], env: %{})
  @version String.trim(version)

  @spec get_version() :: String.t()
  def get_version do
    @version
  end
end
