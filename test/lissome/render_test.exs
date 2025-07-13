defmodule Lissome.RenderTest do
  use LissomeCase, async: true
  alias Lissome.Render

  # Create a simple test module to use in our tests
  defmodule GleamMock do
    def init({:flags, name, count}) do
      {:model, name, count}
    end

    def view({:model, name, count}) do
      :lustre@element@html.div(
        [],
        [
          :lustre@element@html.text("Name: #{name}"),
          :lustre@element@html.text("Count: #{count}")
        ]
      )
    end

    # the mock module get compiled to a module name like this
    def module_name, do: "Elixir.Lissome.RenderTest.GleamMock"
  end

  def ssr_opts do
    [
      init_fn: :init,
      view_fn: :view,
      flags_type: :flags,
      target_id: "app",
      hrl_file_path: mock_hrl_file("gleam_mock_Flags")
    ]
  end

  describe "ssr_lustre/3" do
    test "renders initial HTML with model and flags" do
      flags = %{count: 42, name: "John"}

      result = Render.ssr_lustre(GleamMock, flags, ssr_opts())

      assert is_binary(result)
      assert result =~ "Count: 42"
      assert result =~ "Name: John"
      assert result =~ ~s(id="app")
      assert result =~ ~s(data-name="#{GleamMock.module_name()}")
      assert result =~ ~s(phx-hook="LissomeHook")
    end

    test "includes flags JSON script tag" do
      flags = %{count: 42, name: "John"}
      result = Render.ssr_lustre(GleamMock, flags, ssr_opts())

      assert result =~ ~s(<script id="ls-model" type="application/json">)
      assert result =~ JSON.encode!(flags)
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

      assert result =~ ~s(<script id="ls-model" type="application/json">)
      assert result =~ JSON.encode!(flags)
    end
  end
end
