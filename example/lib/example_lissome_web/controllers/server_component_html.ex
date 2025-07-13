defmodule ExampleLissomeWeb.ServerComponentHTML do
  use ExampleLissomeWeb, :html

  alias Lissome.LustreServerComponent

  def index(assigns) do
    ~H"""
    <LustreServerComponent.render route="/lustre/websocket" />
    """
  end
end
