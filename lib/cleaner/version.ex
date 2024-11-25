defmodule Cleaner.Version do
  @moduledoc false

  # Define the Git version at compile time
  @external_resource git_revision_file = ".git/HEAD"

  # Add dependency on .git/refs if symbolic ref
  if File.exists?(git_revision_file) do
    head_contents = File.read!(git_revision_file)

    if String.starts_with?(head_contents, "ref:") do
      ref_path = String.trim(String.replace(head_contents, "ref:", ""))
      @external_resource ".git/#{ref_path}"
    end
  end

  def get_version do
    # Get git hash
    {version, 0} = System.cmd("git", ["rev-parse", "--short", "HEAD"])
    String.trim(version)
  end
end
