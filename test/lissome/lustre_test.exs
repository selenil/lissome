defmodule Lissome.LustreTest do
  use LissomeCase, async: true
  alias Lissome.Lustre

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
    def module_name, do: "Elixir.Lissome.LustreTest.GleamMock"
  end

  def render_opts do
    [
      entry_fn: :main,
      target_id: "app"
    ]
  end

  def ssr_opts do
    render_opts() ++
      [
        init_fn: :init,
        view_fn: :view,
        flags_type: :flags,
        hrl_file_path: mock_hrl_file("gleam_mock_Flags")
      ]
  end

  describe "server_render/3" do
    test "renders initial HTML with model and flags" do
      flags = %{count: 42, name: "John"}

      result = Lustre.server_render(GleamMock, flags, ssr_opts())

      assert is_binary(result)
      assert result =~ "Count: 42"
      assert result =~ "Name: John"
      assert result =~ ~s(id="app")
      assert result =~ ~s(data-name="#{GleamMock.module_name()}")
      assert result =~ ~s(phx-hook="LissomeHook")
    end

    test "includes flags JSON script tag" do
      flags = %{count: 42, name: "John"}
      result = Lustre.server_render(GleamMock, flags, ssr_opts())

      assert result =~ ~s(<script id="ls-model" type="application/json">)
      assert result =~ JSON.encode!(flags)
    end
  end

  describe "render/3" do
    test "renders container without initial content" do
      flags = %{count: 42, light_on: true}
      result = Lustre.render(GleamMock, flags, render_opts())

      assert is_binary(result)
      assert result =~ ~s(id="app")
      assert result =~ ~s(data-name="#{GleamMock.module_name()}")
      assert result =~ ~s(phx-hook="LissomeHook")
    end

    test "includes flags JSON script tag" do
      flags = %{count: 42, light_on: true}
      result = Lustre.render(GleamMock, flags, render_opts())

      assert result =~ ~s(<script id="ls-model" type="application/json">)
      assert result =~ JSON.encode!(flags)
    end
  end
end
