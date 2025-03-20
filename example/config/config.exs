# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :example_lissome,
  generators: [timestamp_type: :utc_datetime]

# Configures the endpoint
config :example_lissome, ExampleLissomeWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: ExampleLissomeWeb.ErrorHTML, json: ExampleLissomeWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: ExampleLissome.PubSub,
  live_view: [signing_salt: "LQZjybbX"]

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.25.0",
  example_lissome: [
    args:
      ~w(js/app.js --bundle --target=es2020 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "3.4.3",
  example_lissome: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :lissome,
  gleam_dir: "assets/lustre",
  gleam_app: "lustre_app"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
