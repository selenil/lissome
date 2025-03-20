defmodule Mix.Tasks.Compile.Gleam do
  use Mix.Task.Compiler

  @moduledoc """
  Compiles Gleam source files BEAM files.

  This task compiles your Gleam source files in two steps:
    1. First, it uses `gleam build` command to convert Gleam files into Erlang (`.erl`) files
    2. Then it compiles those Erlang files into BEAM bytecode using Erlang's `:code` module

  The resulting BEAM files are placed in your project's build directory under the directory matching your application name.

  Include this task in your project's `mix.exs` with, e.g.:

      def project do
        [
          compilers: Mix.compilers() ++ [:gleam],
        ]
      end

  For other ways to compile Gleam code, see `Mix.Tasks.Lissome.BuildGleam`.
  """
  @impl true
  def run(_) do
    app = Mix.Project.config() |> Keyword.fetch!(:app)
    Lissome.GleamBuilder.build_gleam(:erlang, erlang_outdir: "lib/#{app}")
  end
end
