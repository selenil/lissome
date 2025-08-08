defmodule Lissome.Lustre do
  @moduledoc """
  Module for rendering [Lustre](https://hexdocs.pm/lustre/index.html) applications.
  """

  alias Lissome.Utils
  alias Lissome.GleamType

  @flags_json_tag_id Application.compile_env(:lissome, :flags_json_tag_id, "ls-model")

  @doc """
  Renders a Lustre application.

  Returns a HTML string with a `div` container that will mount the application on the client
  using a Phoenix LiveView hook.

  ## Options

  - `:entry_fn` - The function in the Gleam module that will be called to start the Lustre application (usually `:main`).
  - `:target_id` - The DOM id where the Lustre application should mount.
  """
  def render(module_name, flags, opts) do
    entry_fn = Keyword.fetch!(opts, :entry_fn)
    target_id = Keyword.fetch!(opts, :target_id)

    attrs = container_attrs(module_name, target_id, entry_fn)

    wrap_in_container(attrs, [flags_json_script_tag(flags)])
    |> element_to_string()
  end

  @doc """
  Pre-renders a Lustre application on the server.

  Calls the specified `init_fn` and `view_fn` from the Gleam module to generate the initial HTML,
  and embeds the initial model as JSON for client-side hydration.

  Returns a HTML string containing the initial HTML of the Lustre application wrapped in a `div` container that will start the hydration process on the client using a Phoenix LiveView hook.

  ## Options

  - `:entry_fn` - The function in the Gleam module that will be called to start the Lustre application (usually `:main`).
  - `:init_fn` - The function in the Gleam module to initialize the model (usually `:init`).
  - `:view_fn` - The function in the Gleam module to render the view from a model (usually `:view`).
  - `:flags_type` - The Gleam type of the flags passed. Defaults to `nil`,
  meaning the application does not take any flags.
  - `:hrl_file_path` - Optional path to the `.hrl` file where the Erlang record
  corresponding to the flags type is defined.
  - `:target_id` - The DOM id where the Lustre application should hydrate.
  """
  def server_render(module_name, flags, opts) do
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
        function_exported?(module_name, init_fn, 1) ->
          [flags_tuple]

        function_exported?(module_name, init_fn, 2) ->
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

    attrs = container_attrs(module_name, target_id, entry_fn)

    children =
      [view, flags_json_script_tag(flags)]

    wrap_in_container(attrs, children)
    |> element_to_string()
  end

  @doc """
  Prepares flags to be passed to a Lustre application.

  This function receives the flags Gleam type as an atom and then constructs the
  correct Erlang record using the values passed.

  If the flags type is `nil`, then this function return `nil` too, meaning that the application
  does not takes any flags. Otherwise, returns a tuple with all the flags values
  in the order the Lustre application expects them.

  ## Options

  Same options taken by `Lissome.GleamType.from_record/4`.

  ## Examples

      iex> Lissome.Lustre.process_flags(%{count: 10, label: "Clicks"}, :my_gleam_mod, :flags)
      {:flags, 10, "Clicks"}

      iex> Lissome.Lustre.process_flags(%{count: 10}, :my_gleam_mod, nil)
      nil
  """
  def process_flags(flags, module_name, flags_type, opts \\ [])

  def process_flags(_flags, _module_name, nil, _opts), do: nil

  def process_flags(flags, module_name, flags_type, opts) do
    GleamType.from_record(
      flags_type,
      module_name,
      flags,
      opts
    )
    |> GleamType.to_erlang_tuple()
  end

  @doc """
  Converts a Lustre element tuple to the corresponding HTML string.

  ## Examples

      iex> el = :lustre@element@html.div([], [:lustre@element@html.text("Hello, world!")])
      ...> element_to_string(el)
      "<div>Hello, world!</div>"
  """
  def element_to_string(lustre_html) do
    :lustre@element.to_string(lustre_html)
  end

  defp wrap_in_container(attrs, children) when is_list(attrs) and is_list(children) do
    :lustre@element@html.div(attrs, children)
  end

  defp container_attrs(module_name, target_id, entry_fn) do
    [
      :lustre@attribute.id(target_id),
      :lustre@attribute.attribute("data-name", module_base_name(module_name)),
      :lustre@attribute.attribute("data-entryfn", Atom.to_string(entry_fn)),
      :lustre@attribute.attribute("phx-hook", "LissomeHook"),
      :lustre@attribute.attribute("phx-update", "ignore")
    ]
  end

  defp flags_json_script_tag(flags) do
    :lustre@element@html.script(
      [
        :lustre@attribute.type_("application/json"),
        :lustre@attribute.id(flags_json_tag_id())
      ],
      Utils.json(flags)
    )
  end

  defp flags_json_tag_id, do: @flags_json_tag_id

  defp module_base_name(module_name) do
    module_name |> Atom.to_string() |> String.split("@") |> List.last()
  end
end
