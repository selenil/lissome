defmodule Lissome.Utils do
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
end
