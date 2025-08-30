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

  @doc """
  A JSON string that can be decoded successfully by
  `Lissome.LustreServerComponent.parse_client_message/1`.
  """
  def valid_client_message, do: ~S({"kind":1,"path":"2\n2","name":"click","event":{}})

  @doc """
  A JSON string that cannot be decoded successfully by
  `Lissome.LustreServerComponent.parse_client_message/1`.
  """
  def invalid_client_message, do: ~S({"other from": "Lustre runtime"})

  @doc """
  A valid message sent from a Lustre server component to be sent to the Lustre client runtime.
  """
  def message_to_client, do: {:reconcile, 1, {:patch, 0, 0, [], []}}

  @doc "A JSON payload in a charlist format"
  def json_charlist do
    [
      ~c"{",
      [[34, "kind", 34], 58 | "1"],
      [[44, [34, "patch", 34], 58 | "{}"]],
      ~c"}"
    ]
  end
end
