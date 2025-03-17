defmodule Lissome.MixProject do
  use Mix.Project

  @version "0.2.0"

  @repo_url "https://github.com/selenil/lissome"

  def project do
    [
      app: :lissome,
      name: "Lissome",
      version: @version,
      erlc_paths: [
        "src_gleam/build/dev/erlang/lissome/_gleam_artefacts",
        "src_gleam/build/packages/gleam_stdlib/src",
        "src_gleam/build/packages/lustre/src"
      ],
      compilers: [:elixir] ++ List.delete(Mix.compilers(), :elixir),
      elixir: "~> 1.18",
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
      {:phoenix_live_view, "~> 1.0.0"},
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
      files: ~w(lib mix.exs .formatter.exs LICENSE README.md CHANGELOG.md)
    ]
  end
end
