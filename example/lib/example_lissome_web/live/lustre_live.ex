defmodule ExampleLissomeWeb.LustreLive do
  use ExampleLissomeWeb, :live_view

  import Lissome.Component
  alias Lissome.GleamType

  @initial_count 5

  def mount(_, _, socket) do
    {:ok, assign(socket, count: @initial_count, client_count: nil, light_on: false)}
  end

  def render(assigns) do
    ~H"""
    <div class="container mx-auto px-4 py-8">
      <div class="grid grid-cols-1 md:grid-cols-2 gap-8">
        <div class="p-8 bg-white rounded-xl shadow-lg md:h-[500px]">
          <h2 class="text-2xl font-bold text-center text-gray-800 mb-8">
            LiveView Counter
          </h2>

          <div class="flex flex-col items-center gap-8">
              <div class="flex items-center justify-between w-full max-w-md">
                <div class="flex flex-col items-center gap-2">
                  <div class="text-5xl font-bold text-gray-700">
                    {@count}
                  </div>
                  <div class="text-sm text-gray-500 font-medium">
                    Server Count
                  </div>
                </div>

                <div class="flex flex-col items-center gap-2">
                  <div class="text-5xl font-bold text-gray-700">
                    {@client_count || "..."}
                  </div>
                  <div class="text-sm text-gray-500 font-medium">
                    Client Count
                  </div>
                </div>
              </div>

              <div class="flex gap-4">
                <button
                  class="w-12 h-12 flex items-center justify-center rounded-full bg-liveview-200 text-liveview-700 text-2xl font-bold hover:bg-liveview-300 transition-colors focus:outline-none focus:ring-2 focus:ring-liveview-500 focus:ring-offset-2"
                  phx-click="increment"
                >
                  +
                </button>
                <button
                  class="w-12 h-12 flex items-center justify-center rounded-full bg-liveview-200 text-liveview-700 text-2xl font-bold hover:bg-liveview-300 transition-colors focus:outline-none focus:ring-2 focus:ring-liveview-500 focus:ring-offset-2"
                  phx-click="decrement"
                >
                  -
                </button>
              </div>
            </div>

            <div class="flex flex-col items-center gap-4 mt-8">
              <div class={[
                "w-20 h-20 rounded-full flex items-center justify-center text-lg font-medium transition-colors duration-300",
                @light_on && "bg-liveview-400 text-gray-900 shadow-lg shadow-liveview-200",
                !@light_on && "bg-gray-200 text-gray-600"
              ]}>
                {if @light_on, do: "ON", else: "OFF"}
              </div>

              <button
                class="px-6 py-3 bg-liveview-500 text-white rounded-lg font-medium hover:bg-liveview-600 transition-colors focus:outline-none focus:ring-2 focus:ring-liveview-400 focus:ring-offset-2"
                phx-click="toggle-light"
              >
                Toggle light
              </button>
            </div>
        </div>

        <.lustre ssr={true} name={:hello} flags={%{
          server_count: GleamType.from_value(:some, @count)
        }} flags_type={:flags} />
      </div>
    </div>
    """
  end

  def handle_event("increment", _, socket) do
    {:noreply, update_server_count(socket, socket.assigns.count + 1)}
  end

  def handle_event("decrement", _, socket) do
    {:noreply, update_server_count(socket, socket.assigns.count - 1)}
  end

  def handle_event("update-client-count", client_count, socket) do
    {:noreply, assign(socket, client_count: client_count)}
  end

  def handle_event("toggle-light", _, socket) do
    {:noreply, assign(socket, light_on: !socket.assigns.light_on)}
  end

  defp update_server_count(socket, count) do
    socket
    |> assign(count: count)
    |> push_event("update-client-count", %{server_count: count})
  end
end
