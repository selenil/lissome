defmodule Lissome do
  @moduledoc """
  Integration of Gleam's Lustre framework with Phoenix LiveView
  """

  # build gleam package at compile time
  Lissome.GleamBuilder.build_gleam(
    :erlang,
    erlang_outdir: "lib/lissome/"
  )
end
