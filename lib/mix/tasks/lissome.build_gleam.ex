defmodule Mix.Tasks.Lissome.BuildGleam do
  @moduledoc """
  Builds Gleam source files to either JavaScript or Erlang targets using the `gleam build` command.

  The gleam directory could be specified as an argument. If it is not provided, the path under `:gleam_dir` in the configuration is used with a fallback in case the configuration is not set. See `Lissome.GleamBuilder.build_gleam/1` for more details.

  The default target is Erlang.

  ## Usage:
    mix lissome.build_gleam
    mix lissome.build_gleam --target [javascript | erlang]
    mix lissome.build_gleam "path/to/my_gleam_dir" --target [javascript | erlang]
  """

  use Mix.Task
  import Lissome.GleamBuilder

  @default_target "erlang"

  @impl true
  def run(args) do
    case OptionParser.parse(args, strict: [target: :string]) do
      {[], [], []} ->
        build_gleam(@default_target)

      {[target: target], [], []} when is_valid_target(target) ->
        build_gleam(target)

      {[target: target], [gleam_dir], []} when is_valid_target(target) ->
        build_gleam(target, gleam_dir: gleam_dir)

      {_, [gleam_dir], []} ->
        build_gleam(@default_target, gleam_dir: gleam_dir)

      _ ->
        Mix.raise("""
        Invalid arguments.

        Run `mix help lissome.build_gleam` for more information about how to use this task.
        """)
    end
  end
end
