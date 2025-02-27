defmodule Lissome.RenderTest do
  use ExUnit.Case
  alias Lissome.Render

  # Create a simple test module to use in our tests
  defmodule GleamMock do
    def init({:flags, flags}) do
      {:ok, flags}
    end

    def view({:model, count, light_on}) do
      :lustre@element@html.div(
        [],
        [
          :lustre@element@html.text("Count: #{count}"),
          :lustre@element@html.text("Light: #{light_on}")
        ]
      )
    end

    # the mock module get compiled to a module name like this
    def module_name, do: "Elixir.Lissome.RenderTest.GleamMock"
  end

  describe "ssr_lustre/5" do
    test "renders initial HTML with model and flags" do
      flags = %{count: 42, light_on: true}
      result = Render.ssr_lustre(GleamMock, "init", "view", "app", flags)

      assert is_binary(result)
      assert result =~ "Count: 42"
      assert result =~ "Light: true"
      assert result =~ ~s(id="app")
      assert result =~ ~s(data-name="#{GleamMock.module_name()}")
      assert result =~ ~s(phx-hook="LissomeHook")
    end

    test "includes flags JSON script tag" do
      flags = %{count: 42, light_on: true}
      result = Render.ssr_lustre(GleamMock, "init", "view", "app", flags)

      assert result =~ ~s(<script type="application/json" id="ls-model">)
      assert result =~ Elixir.JSON.encode!(flags)
    end
  end

  describe "render_lustre/3" do
    test "renders container without initial content" do
      flags = %{count: 42, light_on: true}
      result = Render.render_lustre(GleamMock, "app", flags)

      assert is_binary(result)
      assert result =~ ~s(id="app")
      assert result =~ ~s(data-name="#{GleamMock.module_name()}")
      assert result =~ ~s(phx-hook="LissomeHook")
    end

    test "includes flags JSON script tag" do
      flags = %{count: 42, light_on: true}
      result = Render.render_lustre(GleamMock, "app", flags)

      assert result =~ ~s(<script type="application/json" id="ls-model">)
      assert result =~ Elixir.JSON.encode!(flags)
    end
  end
end
