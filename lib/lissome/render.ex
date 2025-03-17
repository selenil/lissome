defmodule Lissome.Render do
  alias Lissome.Utils

  @doc """
  Renders a lustre app in server side.

  This function will call the `init_fn` function to get the initial model and then the `view_fn` function to get the initial view.
  """
  def ssr_lustre(module_name, init_fn, view_fn, target_id, flags) do
    init_fn = String.to_atom(init_fn)
    view_fn = String.to_atom(view_fn)

    Code.ensure_loaded!(module_name)

    init_args =
      cond do
        :erlang.function_exported(module_name, init_fn, 1) ->
          [{:flags, flags}]

        :erlang.function_exported(module_name, init_fn, 2) ->
          [{:flags, flags}, nil]

        true ->
          raise "The init function must be avaliable and have arity 1 or 2"
      end

    model =
      module_name
      |> apply(init_fn, init_args)
      |> case do
        {{_, model}, _effect} ->
          model

        {_, model} ->
          model
      end

    view =
      apply(module_name, view_fn, [model_to_tuple(model)])

    flags_json_tag = flags_json_script_tag(flags)

    module_base_name = module_base_name(module_name)

    module_base_name
    |> wrap_in_container(target_id, [view, flags_json_tag])
    |> lustre_to_string()
  end

  @doc """
  Renders a lustre app in client side.

  This function just renders the root container and the script tags necessary to mount the app.
  """
  def render_lustre(module_name, target_id, flags) do
    module_base_name = module_base_name(module_name)

    flags_json_tag = flags_json_script_tag(flags)

    module_base_name
    |> wrap_in_container(target_id, [flags_json_tag])
    |> lustre_to_string()
  end

  defp model_to_tuple(model) when is_map(model) do
    model
    |> Map.values()
    |> List.to_tuple()
    |> Tuple.insert_at(0, :model)
  end

  defp wrap_in_container(module_name, target_id, children) when is_list(children) do
    :lustre@element@html.div(
      [
        :lustre@attribute.id(target_id),
        :lustre@attribute.attribute("data-name", module_name),
        :lustre@attribute.attribute("phx-hook", "LissomeHook"),
        :lustre@attribute.attribute("phx-update", "ignore")
      ],
      children
    )
  end

  defp flags_json_script_tag(flags) do
    flags_json_tag_id = Application.get_env(:lissome, :flags_json_tag_id, "ls-model")

    :lustre@element@html.script(
      [
        :lustre@attribute.type_("application/json"),
        :lustre@attribute.id(flags_json_tag_id)
      ],
      Utils.json(flags)
    )
  end

  defp module_base_name(module_name) do
    module_name |> Atom.to_string() |> String.split("@") |> List.last()
  end

  defp lustre_to_string(lustre_html) do
    :lustre@element.to_string(lustre_html)
  end
end
