defmodule ExampleLissomeWeb.LustreSocket do
  use Lissome.LustreServerComponent

  def child_spec(_opts) do
    :ignore
  end

  def connect(state) do
    {:ok, state}
  end

  def init(state) do
    server_component = start_server_component!(:monitor, nil)
    subject = subscribe_to_server_component(server_component)

    state =
      state
      |> Map.put(:server_component, server_component)
      |> Map.put(:subject, subject)

    {:ok, state}
  end

  def handle_in({msg, _}, state) do
    runtime_message = parse_client_message!(msg)
    send_to_server_component(state.server_component, runtime_message)

    {:ok, state}
  end

  def handle_info({_ref, msg}, state) do
    json =
      msg
      |> encode_client_message()
      |> json_to_string()

    {:push, {:text, json}, state}
  end

  def handle_info(_message, state) do
    {:noreply, state}
  end

  def terminate(_reason, state) do
    unsubscribe_from_server_component(state.server_component, state.subject)
  end
end
