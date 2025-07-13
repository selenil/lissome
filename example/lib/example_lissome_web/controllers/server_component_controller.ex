defmodule ExampleLissomeWeb.ServerComponentController do
  use ExampleLissomeWeb, :controller

  def index(conn, _params) do
    render(conn, :index)
  end
end
