defmodule Lissome do
  @moduledoc """
  Integration of Gleam's Lustre framework with Phoenix LiveView
  """

  @gleam_package_path File.cwd!() |> Path.join("src_gleam") |> Path.expand()

  defimpl JSON.Encoder, for: Lissome.GleamType do
    def encode(%Lissome.GleamType{values: values, record?: true}, opts) do
      values
      |> Lissome.GleamType.flat_tuple_map()
      |> JSON.Encoder.Map.encode(opts)
    end

    def encode(%Lissome.GleamType{values: value}, opts) do
      JSON.Encoder.encode(value, opts)
    end
  end

  # build gleam package at compile time
  Lissome.GleamBuilder.build_gleam(
    :erlang,
    gleam_dir: @gleam_package_path,
    erlang_outdir: "lib/lissome/"
  )
end
