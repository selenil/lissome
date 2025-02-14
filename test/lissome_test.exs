defmodule LissomeTest do
  use ExUnit.Case
  doctest Lissome

  test "greets the world" do
    assert Lissome.hello() == :world
  end
end
