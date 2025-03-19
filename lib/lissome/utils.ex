defmodule Lissome.Utils do
  @gleam_dir Application.compile_env(:lissome, :gleam_dir, "assets/lustre_app")
  @gleam_app Application.compile_env(:lissome, :gleam_app, "lustre_app")

  @doc """
  Turns a module name into a valid Gleam module name.

  Gleam uses `@` to separate paths in module names. For example, a module
  in the directory `src/pages/home` would be compiled as `pages@home`. We process the path to turn it into the correct erlang module name that we can call in Elixir.

  ## Examples:

    iex> Lissome.Utils.format_module_name("nested/nested/nested/mod")
    :nested@nested@nested@mod

    iex> Lissome.Utils.format_module_name("home")
    :home
  """
  def format_module_name(module_path) do
    module_path
    |> Path.split()
    |> Enum.join("@")
    |> String.to_atom()
  end

  def json(data), do: Elixir.JSON.encode!(data)

  def gleam_build_path(),
    do: Path.join(@gleam_dir, "build")

  def get_gleam_app_from_config do
    @gleam_app
  end

  # replace this with a call to the gleam export package-info
  # command when it's added to gleam
  def extract_gleam_app_name(gleam_dir) do
    content =
      gleam_dir
      |> Path.join("gleam.toml")
      |> File.read!()

    Regex.run(~r/name = "(.*)"/, content) |> List.last()
  end
end
