defmodule ExampleLissome.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    :hell
    children = [
      ExampleLissomeWeb.Telemetry,
      {DNSCluster, query: Application.get_env(:example_lissome, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: ExampleLissome.PubSub},
      # Start a worker by calling: ExampleLissome.Worker.start_link(arg)
      # {ExampleLissome.Worker, arg},
      # Start to serve requests, typically the last entry
      ExampleLissomeWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ExampleLissome.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ExampleLissomeWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
