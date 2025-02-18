defmodule Lissome.Component do
  use Phoenix.Component

  alias Lissome.Render
  alias Lissome.Utils

  attr(
    :name,
    :string,
    required: true,
    doc: "The name of the Gleam module to render relative to the src directory",
    examples: ["my_lustre_app", "pages/home"]
  )

  attr(
    :flags,
    :map,
    default: %{},
    doc: "Initial values to pass to the Gleam module",
    examples: [
      %{
        name: "John",
        age: 30
      }
    ]
  )

  attr(
    :init_fn,
    :string,
    default: "init",
    doc: "the name of your Gleam function that initializes the model"
  )

  attr(
    :view_fn,
    :string,
    default: "view",
    doc: "the name of your Gleam function that renders the view"
  )

  attr(
    :id,
    :string,
    default: "app",
    doc: "The id Lustre targets to render into"
  )

  attr(
    :class,
    :string,
    default: "",
    doc: "The class name to apply to the rendered app"
  )

  attr(
    :ssr,
    :boolean,
    default: true,
    doc: "Whether to render the app on the server side"
  )

  @doc """
  Renders a lustre app.
  """
  def lustre(assigns) do
    module_name = Utils.format_module_name(assigns[:name])

    render_code =
      if assigns[:ssr] do
        Render.ssr_lustre(
          module_name,
          assigns[:init_fn],
          assigns[:view_fn],
          assigns[:id],
          assigns[:flags]
        )
      else
        Render.render_lustre(module_name, assigns[:id], assigns[:flags])
      end

    assigns =
      assigns
      |> assign(:render_code, render_code)

    ~H"""
      {Phoenix.HTML.raw(@render_code)}
    """
  end
end
