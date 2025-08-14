defmodule Lissome do
  @moduledoc """
  Integration of Gleam's Lustre framework with Phoenix LiveView
  """

  @gleam_package_path File.cwd!() |> Path.join("src_gleam") |> Path.expand()

  # build gleam package at compile time
  Lissome.GleamBuilder.build_gleam(
    :erlang,
    gleam_dir: @gleam_package_path,
    erlang_outdir: "lib/lissome/"
  )
end
