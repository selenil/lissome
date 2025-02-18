defmodule ExampleLissomeWeb.LustreLive do
  use ExampleLissomeWeb, :live_view

  import Lissome.Component

  def mount(_, _, socket) do
    {:ok, assign(socket, count: 0, light_on: false)}
  end

  def render(assigns) do
    ~H"""
    <div class="flex flex-col items-center gap-8 md:flex-row max-w-md mx-auto">
      <div class="max-w-md mx-auto p-8 bg-white rounded-lg shadow-lg">
      <p class="text-3xl font-bold text-center text-gray-800 mb-8">
        LiveView
      </p>

      <div class="flex items-center justify-center gap-4 mb-8">
        <button
          class="w-8 h-8 flex items-center justify-center rounded-full bg-orange-200 text-orange-700 text-2xl font-bold hover:bg-orange-300 focus:outline-none focus:ring-2 focus:ring-orange-500 focus:ring-offset-2"
          phx-click="decrement"
        >
          -
        </button>

        <div class="text-4xl font-bold text-gray-700 w-16 text-center">
          <%= @count %>
        </div>

        <button
          class="w-8 h-8 flex items-center justify-center rounded-full bg-orange-200 text-orange-700 text-2xl font-bold hover:bg-orange-300 focus:outline-none focus:ring-2 focus:ring-orange-500 focus:ring-offset-2"
          phx-click="increment"
        >
          +
        </button>
      </div>

      <div class="flex flex-col items-center gap-4">
        <div class={[
          "w-16 h-16 rounded-full flex items-center justify-center transition-colors duration-300",
          @light_on && "bg-orange-400 text-gray-900",
          !@light_on && "bg-red-300 text-white"
        ]}>
          <%= if @light_on, do: "ON", else: "OFF" %>
        </div>

        <button
          class="px-6 py-2 bg-red-500 text-white rounded-md hover:bg-red-600 focus:outline-none focus:ring-2 focus:ring-red-400 focus:ring-offset-2"
          phx-click="toggle_light"
        >
          Toggle light
        </button>
      </div>
      </div>
      <.lustre name="hello" flags={%{count: 5, light_on: true}} />
    </div>
    """
  end

  def handle_event("increment", _, socket) do
    {:noreply, assign(socket, count: socket.assigns.count + 1)}
  end

  def handle_event("decrement", _, socket) do
    {:noreply, assign(socket, count: socket.assigns.count - 1)}
  end

  def handle_event("toggle_light", _, socket) do
    {:noreply, assign(socket, light_on: !socket.assigns.light_on)}
  end
end
