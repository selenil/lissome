defmodule ExampleLissomeWeb.Router do
  use ExampleLissomeWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {ExampleLissomeWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", ExampleLissomeWeb do
    pipe_through :browser

    live "/", LustreLive
    get "/server-component", ServerComponentController, :index
  end

  # Other scopes may use custom stacks.
  # scope "/api", ExampleLissomeWeb do
  #   pipe_through :api
  # end
end
