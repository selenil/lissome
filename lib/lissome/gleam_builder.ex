defmodule Lissome.GleamBuilder do
  @moduledoc """
  Wrapper around the Gleam build tool.

  This module provides functionality to build Gleam source files to either JavaScript or Erlang targets using the `gleam build` command.
  """

  @gleam_pattern "**/*.gleam"

  @doc """
  Builds Gleam source files to the specified target.

  ## Parameters

    * `gleam_dir` - The root directory containing the Gleam project
    * `target` - The build target, either `:javascript` or `:erlang`

  Returns `:ok`.
  """
  def build_gleam(gleam_dir, target) do
    gleam_src = Path.join(gleam_dir, "src")

    gleam_files =
      gleam_src
      |> Path.join(@gleam_pattern)
      |> Path.wildcard()

    gleam? =
      File.exists?(gleam_src) and not Enum.empty?(gleam_files)

    if gleam?, do: build(target, gleam_dir)

    :ok
  end

  defp build(target, gleam_dir) when is_atom(target) do
    target = Atom.to_string(target)
    cmd("gleam", ["build", "--target", target], cd: gleam_dir)
  end

  defp cmd(command, args, opts) do
    opts =
      Keyword.merge(
        opts,
        into: IO.stream(:stdio, :line),
        stderr_to_stdout: true
      )

    System.cmd(command, args, opts)
  end
end
