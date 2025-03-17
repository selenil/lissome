if Code.ensure_loaded?(FileSystem) do
  defmodule Lissome.GleamReloader do
    @moduledoc """
    A `GenServer` to watch for changes to Gleam files and recompile them.

    This module requires the `FileSystem` package, which is not included with Lissome. In typical Phoenix projects, `FileSystem` is already available in the `:dev` environment through `phoenix_live_reload`.
    """

    import Lissome.GleamBuilder

    @doc """
    Registers a new target for the Gleam reloader to watch and compile.

    This function starts a new reloader GenServer if one doesn't exist, or adds the target to an existing GenServer.
    """
    def register_target(target, path \\ nil) when is_valid_target(target) do
      case start_link(targets: [target], path: path) do
        {:ok, _pid} ->
          :ok

        {:error, {:already_started, pid}} ->
          send(pid, {:register_target, target})
      end
    end

    @doc """
    Starts the Gleam reloader GenServer.
    """
    def start_link(args) do
      targets = Keyword.fetch!(args, :targets)
      path = Keyword.fetch!(args, :path)

      GenServer.start_link(
        __MODULE__,
        %{targets: targets, path: path},
        name: __MODULE__
      )
    end

    def init(args) do
      dirs = ["src", "test"] |> Enum.map(&Path.join(args[:path], &1))
      {:ok, pid} = FileSystem.start_link(dirs: dirs)
      FileSystem.subscribe(pid)

      {:ok, args}
    end

    def handle_info({:file_event, _watcher, _event}, state) do
      run_gleam_compiler(state[:targets], state[:path])
      {:noreply, state}
    end

    def handle_info({:register_target, target}, state) do
      state = Map.put(state, :targets, [target | state[:targets]])
      {:noreply, state}
    end

    defp run_gleam_compiler(targets, path) do
      build_gleam(
        targets,
        gleam_dir: path,
        compile_package: true
      )
    end
  end
end
