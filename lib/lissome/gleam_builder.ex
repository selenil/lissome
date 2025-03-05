defmodule Lissome.GleamBuilder do
  @moduledoc """
  Wrapper around the Gleam build tool.

  This module provides functionality to build Gleam source files to either JavaScript or Erlang targets using the `gleam build` command.
  """

  @gleam_pattern "**/*.gleam"
  @default_gleam_dir "assets/lustre"
  @doc """
  Builds Gleam source files to the specified target.

  If the target is `:erlang`, the compiled modules will be loaded.

  ## Parameters
    * `target` - The build target, either `:javascript` or `:erlang`. Uses the configured `:gleam_dir` from application config, defaulting to #{@default_gleam_dir}

  Returns `:ok`.
  """
  def build_gleam(target) do
    gleam_dir = Application.get_env(:lissome, :gleam_dir, @default_gleam_dir)
    build_gleam(target, gleam_dir)
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
    build(target, gleam_dir)
  end

  defp build(target, gleam_dir) when is_binary(target) do
    {_, exit_code} = cmd("gleam", ["build", "--target", target], cd: gleam_dir)

    if exit_code == 0 and target == "erlang",
      do: compile_and_load_erlang_modules(gleam_dir)
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

  defp compile_and_load_erlang_modules(gleam_dir) do
    gleam_app_name =
      extract_gleam_app_name(gleam_dir)

    build_path = "build/dev/erlang/#{gleam_app_name}/_gleam_artefacts/"

    outdir =
      Mix.Project.build_path()
      |> Path.join("lib/_#{gleam_app_name}/ebin")
      |> String.to_charlist()

    File.mkdir_p!(outdir)
    :code.add_patha(outdir)

    gleam_dir
    |> Path.join([build_path, "**/*.erl"])
    |> Path.wildcard()
    |> Enum.each(fn file ->
      file = String.replace(file, ".erl", "") |> String.to_charlist()

      {:ok, module} =
        :compile.file(file, [
          :report_errors,
          :report_warnings,
          {:outdir, outdir}
        ])

      :code.load_file(module)
    end)
  end

  # replace this with a call to the gleam export package-info
  # command when it's added to gleam
  defp extract_gleam_app_name(gleam_dir) do
    content =
      gleam_dir
      |> Path.join("gleam.toml")
      |> File.read!()

    Regex.run(~r/name = "(.*)"/, content) |> List.last()
  end
end
