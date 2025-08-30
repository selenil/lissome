defmodule Lissome.Component do
  use Phoenix.Component

  alias Lissome.Lustre

  attr(
    :name,
    :atom,
    required: true,
    doc: "The name of the Gleam module to render relative to the src directory",
    examples: [:my_lustre_app, :pages@home]
  )

  attr(
    :flags,
    :any,
    default: nil,
    doc: "Initial values to pass to the Gleam module",
    examples: [
      %{
        name: "John",
        age: 30
      }
    ]
  )

  attr(
    :entry_fn,
    :atom,
    default: :main,
    doc: "The name of your Gleam function that starts the Lustre application"
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
    default: nil,
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
        Lustre.server_render(
          assigns[:name],
          assigns[:flags],
          entry_fn: assigns[:entry_fn],
          init_fn: assigns[:init_fn],
          view_fn: assigns[:view_fn],
          flags_type: assigns[:flags_type],
          target_id: assigns[:id]
        )
      else
        Lustre.render(
          assigns[:name],
          assigns[:flags],
          entry_fn: assigns[:entry_fn],
          target_id: assigns[:target_id]
        )
      end

    assigns = assign(assigns, :render_code, render_code)

    ~H"""
      {Phoenix.HTML.raw(@render_code)}
    """
  end
end
