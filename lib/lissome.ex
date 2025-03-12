defmodule Lissome do
  @moduledoc """
  Integration of Gleam's Lustre framework with Phoenix LiveView
  """

  @gleam_package_path File.cwd!() |> Path.join("src_gleam") |> Path.expand()

  # load gleam package at compile time
  Lissome.GleamBuilder.build_gleam(
    :erlang,
    gleam_dir: @gleam_package_path,
    compile_package: true,
    gleam_app: "lissome"
  )
end
