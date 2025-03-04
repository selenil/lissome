defmodule Lissome.GleamBuilder do
  @moduledoc """
  Wrapper around the Gleam build tool.

  This module provides functionality to build Gleam source files to either JavaScript or Erlang targets using the `gleam build` command.
  """

  @gleam_pattern "**/*.gleam"
  @default_gleam_dir "assets/lustre"
  @doc """
  Builds Gleam source files to the specified target.

  ## Parameters
    * `target` - The build target, either `:javascript` or `:erlang`. Uses the configured `:gleam_dir` from application config, defaulting to #{@default_gleam_dir}

  Returns `:ok`.
  """
  def build_gleam(target) do
    gleam_dir = Application.get_env(:lissome, :gleam_dir, @default_gleam_dir)
    build_gleam(gleam_dir, target)
  end

  @doc """
  Same as `build_gleam/1`, but accepts the gleam directory path as its second argument.
  """
  def build_gleam(target, gleam_dir) do
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
