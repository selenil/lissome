defmodule Lissome.MixProject do
  use Mix.Project
  @app :lissome

  def project do
    [
      app: @app,
      name: "#{@app}",
      version: "0.1.0",
      elixir: "~> 1.18",
      archives: [mix_gleam: "~> 0.6"],
      compilers: [:gleam] ++ Mix.compilers(),
      erlc_paths: ["build/dev/erlang/#{@app}/_gleam_artefacts"],
      erlc_include_path: "build/dev/erlang/#{@app}/include",
      prune_code_paths: false,
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:esbuild, "~> 0.9"},
      {:phoenix, "~> 1.7.18"},
      {:phoenix_html, "~> 4.1"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_live_view, "~> 1.0.0"},

      # gleam dependencies
      {:gleam_stdlib, "~> 0.34 or ~> 1.0"},
      {:gleeunit, "~> 1.0", only: [:dev, :test], runtime: false},
      {:lustre, "~> 4.6.3"}
    ]
  end

  defp aliases do
    [
      "deps.get": ["deps.get", "gleam.deps.get"]
    ]
  end
end
