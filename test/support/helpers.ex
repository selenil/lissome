defmodule Lissome.TestHelpers do
  @moduledoc false

  @doc """
  Returns the path to a `.hrl` file with the given name inside `test/include`.

  Useful for testing functions that read an .hrl file and generate a record from it.
  """
  def mock_hrl_file(name) do
    File.cwd!()
    |> Path.join("test/include/#{name}.hrl")
    |> Path.expand()
  end
end
