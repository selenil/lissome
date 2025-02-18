defmodule Lissome.MixProject do
  use Mix.Project

  @app :lissome
  @version "0.2.0"

  @repo_url "https://github.com/selenil/lissome"

  def project do
    [
      app: @app,
      name: "Lissome",
      version: @version,
      elixir: "~> 1.18",
      archives: [mix_gleam: "~> 0.6"],
      compilers: [:gleam] ++ Mix.compilers(),
      erlc_paths: ["build/dev/erlang/#{@app}/_gleam_artefacts"],
      erlc_include_path: "build/dev/erlang/#{@app}/include",
      prune_code_paths: false,
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases(),

      # Hex
      description: description(),
      package: package(),

      # Docs
      docs: [
        source_ref: "v#{@version}",
        source_url: @repo_url,
        homepage_url: @repo_url,
        main: "readme",
        extras: ["README.md"],
        links: %{
          "GitHub" => @repo_url
        }
      ]
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

  defp description do
    "Integration of Gleam's Lustre framework with Phoenix LiveView"
  end

  defp package do
    [
      maintainers: [""],
      licenses: ["MIT"],
      links: %{
        Changelog: @repo_url <> "/blob/main/CHANGELOG.md",
        GitHub: @repo_url
      },
      files: ~w(lib mix.exs .formatter.exs LICENSE README.md CHANGELOG.md)
    ]
  end
end
