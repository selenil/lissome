defmodule LissomeCase do
  @moduledoc false

  use ExUnit.CaseTemplate

  using do
    quote do
      import Lissome.TestHelpers
    end
  end
end
