defmodule Lissome.LustreServerComponentTest do
  use LissomeCase, async: true
  alias Lissome.LustreServerComponent

  defmodule LustreServerComponentGleamMock do
    @mock_model {nil, {:effect, [], [], []}}
    @mock_view {:element, 1, "", &:gleam@function.identity/1, "", "div", [], [], %{}, false,
                false}

    def component,
      do: {
        :app,
        fn _ -> @mock_model end,
        fn _, _ -> @mock_model end,
        fn _ -> @mock_view end,
        {:config, false, true, %{}, %{}, false, :none, :none, :none}
      }
  end

  describe "start_server_component/3 and start_server_component!/3" do
    test "starts a server component and returns {:ok, server_component}" do
      assert {:ok, {_, pid, _}} =
               LustreServerComponent.start_server_component(LustreServerComponentGleamMock, nil)

      assert is_pid(pid)
      assert Process.alive?(pid)
    end

    test "start_server_component!/3 raises on error" do
      assert_raise ArgumentError, fn ->
        LustreServerComponent.start_server_component!(:not_available_module, nil)
      end
    end
  end

  describe "subscribe_to_server_component/2 and unsubscribe_from_server_component/2" do
    setup do
      {:ok, server_component} =
        LustreServerComponent.start_server_component(LustreServerComponentGleamMock, nil)

      %{server_component: server_component}
    end

    test "subscribes and unsubscribes a process", %{server_component: server_component} do
      {:client_registered_subject, {_, pid, _}} =
        subject =
        LustreServerComponent.subscribe_to_server_component(server_component)

      assert is_pid(pid)
      assert self() == pid

      assert :ok =
               LustreServerComponent.unsubscribe_from_server_component(server_component, subject)
    end
  end

  describe "parse_client_message/1 and parse_client_message!/1" do
    test "parses valid json and returns {:ok, data}" do
      assert {:ok, data} = LustreServerComponent.parse_client_message(valid_client_message())
      assert is_tuple(data)
    end

    test "returns {:error, errors} for invalid json" do
      assert {:error, errors} =
               LustreServerComponent.parse_client_message(invalid_client_message())

      assert is_list(errors)
    end

    test "parse_client_message! returns data or raises on error" do
      assert is_tuple(LustreServerComponent.parse_client_message!(valid_client_message()))

      assert_raise RuntimeError, fn ->
        LustreServerComponent.parse_client_message!(invalid_client_message())
      end
    end
  end

  describe "encode_client_message/1" do
    test "encodes a message to a charlist" do
      result = LustreServerComponent.encode_client_message(message_to_client())
      assert is_list(result)
    end
  end

  describe "json_to_string/1" do
    test "converts a charlist to string" do
      charlist = json_charlist()
      string = LustreServerComponent.json_to_string(charlist)
      assert is_binary(string)
      assert String.contains?(string, "kind")
    end

    test "returns binary unchanged" do
      assert LustreServerComponent.json_to_string("foo") == "foo"
    end
  end
end
