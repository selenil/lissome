defmodule LissomeTest do
  use ExUnit.Case
  doctest Lissome.Utils

  test "can call Gleam code" do
    assert :gleam@list.reverse([1, 2, 3]) == [3, 2, 1]
  end
end
