defmodule Lissome.Component do
  use Phoenix.Component

  alias Lissome.Render

  attr(
    :name,
    :atom,
    required: true,
    doc: "The name of the Gleam module to render relative to the src directory",
    examples: [:my_lustre_app, :pages@home]
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
    :atom,
    default: :init,
    doc: "The name of your Gleam function that initializes the model"
  )

  attr(
    :view_fn,
    :atom,
    default: :view,
    doc: "The name of your Gleam function that renders the view"
  )

  attr(
    :flags_type,
    :atom,
    default: :model,
    doc: "The name of your Gleam type that represents the flags your init function receives."
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
    default: false,
    doc: "Whether to render the app on the server side"
  )

  @doc """
  Renders a lustre app.
  """
  def lustre(assigns) do
    render_code =
      if assigns[:ssr] do
        Render.ssr_lustre(
          assigns[:name],
          assigns[:flags],
          init_fn: assigns[:init_fn],
          view_fn: assigns[:view_fn],
          flags_type: assigns[:flags_type],
          target_id: assigns[:id]
        )
      else
        Render.render_lustre(assigns[:name], assigns[:id], assigns[:flags])
      end

    assigns = assign(assigns, :render_code, render_code)

    ~H"""
      {Phoenix.HTML.raw(@render_code)}
    """
  end
end
