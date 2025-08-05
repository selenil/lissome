defmodule Lissome.Render do
  alias Lissome.Utils
  alias Lissome.GleamType

  @doc """
  Renders a lustre app in server side.

  This function will call the `init_fn` function to get the initial model and then the `view_fn` function to get the initial view.
  """
  def ssr_lustre(module_name, flags, opts) do
    Code.ensure_loaded!(module_name)

    entry_fn = Keyword.fetch!(opts, :entry_fn)
    init_fn = Keyword.fetch!(opts, :init_fn)
    view_fn = Keyword.fetch!(opts, :view_fn)
    flags_type = Keyword.fetch!(opts, :flags_type)
    target_id = Keyword.fetch!(opts, :target_id)

    hrl_file_path = Keyword.get(opts, :hrl_file_path, nil)
    flags_tuple = process_flags(flags, module_name, flags_type, hrl_file_path: hrl_file_path)

    init_args =
      cond do
        :erlang.function_exported(module_name, init_fn, 1) ->
          [flags_tuple]

        :erlang.function_exported(module_name, init_fn, 2) ->
          [flags_tuple, nil]

        true ->
          raise "The init function must be avaliable and have arity 1 or 2"
      end

    model =
      module_name
      |> apply(init_fn, init_args)
      |> case do
        {model, _effect} ->
          model

        model ->
          model
      end

    view =
      apply(module_name, view_fn, [model])

    flags_json_tag = flags_json_script_tag(flags)

    module_base_name = module_base_name(module_name)

    module_base_name
    |> wrap_in_container(entry_fn, target_id, [view, flags_json_tag])
    |> lustre_to_string()
  end

  @doc """
  Renders a lustre app in client side.

  This function just renders the root container and the script tags necessary to mount the app.
  """
  def render_lustre(module_name, flags, opts) do
    entry_fn = Keyword.fetch!(opts, :entry_fn)
    target_id = Keyword.fetch!(opts, :target_id)

    module_base_name = module_base_name(module_name)

    flags_json_tag = flags_json_script_tag(flags)

    module_base_name
    |> wrap_in_container(entry_fn, target_id, [flags_json_tag])
    |> lustre_to_string()
  end

  def process_flags(flags, module_name, flags_type, opts \\ [])

  def process_flags(_flags, _module_name, nil, _opts), do: nil

  def process_flags(flags, module_name, flags_type, opts) do
    GleamType.from_record(
      flags_type,
      module_name,
      flags,
      hrl_file_path: opts[:hrl_file_path]
    )
    |> GleamType.to_erlang_tuple()
  end

  defp wrap_in_container(module_name, entry_fn, target_id, children) when is_list(children) do
    :lustre@element@html.div(
      [
        :lustre@attribute.id(target_id),
        :lustre@attribute.attribute("data-name", module_name),
        :lustre@attribute.attribute("data-entryfn", Atom.to_string(entry_fn)),
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

  def lustre_to_string(lustre_html) do
    :lustre@element.to_string(lustre_html)
  end
end
