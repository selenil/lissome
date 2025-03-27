defmodule Lissome.MixProject do
  use Mix.Project

  @version "0.3.1"

  @repo_url "https://github.com/selenil/lissome"

  def project do
    [
      app: :lissome,
      name: "Lissome",
      version: @version,
      elixir: "~> 1.18",
      erlc_paths: [
        "src_gleam/build/packages/gleam_stdlib/src",
        "src_gleam/build/packages/lustre/src"
      ],
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),

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
        },
        filter_modules: ~r/^Elixir.*/
      ]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:phoenix_live_view, "~> 1.0.0"},
      {:gleam_stdlib, "~> 0.44", app: false},
      {:lustre, "~> 4.6.4", app: false},
      {:file_system, "~> 0.3 or ~> 1.0", optional: true},
      {:ex_doc, "~> 0.34", only: :dev, runtime: false}
    ]
  end

  defp description do
    "Integration of Gleam's Lustre framework with Phoenix LiveView"
  end

  defp package do
    [
      maintainers: ["selenil"],
      licenses: ["MIT"],
      links: %{
        Changelog: @repo_url <> "/blob/main/CHANGELOG.md",
        GitHub: @repo_url
      },
      files:
        ~w(lib assets src_gleam/src src_gleam/test src_gleam/gleam.toml src_gleam/manifest.toml src_gleam/README.md  mix.exs .formatter.exs LICENSE README.md CHANGELOG.md)
    ]
  end
end
