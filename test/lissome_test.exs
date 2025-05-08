defmodule LissomeTest do
  use ExUnit.Case

  test "can call Gleam code" do
    assert :gleam@list.reverse([1, 2, 3]) == [3, 2, 1]
  end

  test "can call code from the Lissome Gleam package" do
    assert Code.ensure_loaded?(:lissome)
    assert Code.ensure_loaded?(:lissome@live_view)

    assert :lissome.get_flags("mock-id", "mock-decoder") == {:error, :not_a_browser}

    push_event_result =
      :lissome@live_view.push_event(
        "mock-hook",
        "mock-event",
        nil,
        fn _ -> nil end
      )

    push_event_to_result =
      :lissome@live_view.push_event_to(
        "mock-hook",
        "mock-query-selector",
        "mock-event",
        nil,
        fn _ -> nil end
      )

    handle_event_result =
      :lissome@live_view.handle_event(
        "mock-hook",
        "mock-event",
        fn _ -> nil end
      )

    assert Enum.all?(
             [push_event_result, push_event_to_result, handle_event_result],
             &(is_tuple(&1) && tuple_size(&1) == 4 && elem(&1, 0) == :effect)
           )
  end
end
