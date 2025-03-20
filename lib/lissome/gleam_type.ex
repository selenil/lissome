defmodule Lissome.GleamType do
  @moduledoc """
  Helpers to work with Gleam types and their Erlang representations.
  """

  alias Lissome.Utils

  @typedoc """
  The GleamType struct type.
  """
  @type t() :: %__MODULE__{
          name: atom(),
          values: any()
        }

  defstruct [:name, :values, :record?]

  @doc """
  Checks if a value is a GleamType struct.

  ## Examples

      iex> gleam_type?(%Lissome.GleamType{})
      true

      iex> gleam_type?("not a gleam type")
      false
  """
  def gleam_type?(value), do: is_struct(value, __MODULE__)

  @doc """
  Creates a new GleamType from a type name and value.

  This function only wraps the value in a tuple with the type name.
  For cases where the type has multiple fields, use `from_record/4` instead.

  ## Examples

      iex> from_value(:some, "hello")
      %GleamType{name: :some, values: "hello"}

      iex> from_value(:error, "something went wrong")
      %GleamType{name: :error, values: "something went wrong"}
  """
  def from_value(type, value) do
    %__MODULE__{name: type, values: value}
  end

  @doc """
  Creates a GleamType from a Gleam record.

  Extracts record information from the corresponding .hrl file and builds a GleamType with the proper structure. Each field is stored with the index where that field should be in the Erlang tuple.

  ## Options

    * `:hrl_file_path` - Path to the .hrl file where the record is defined.Defaults to `{gleam_dir}/build/dev/erlang/{gleam_app}/{module}_{capitalized_type}.hrl`, where:
      - `gleam_dir` is  the value of `:gleam_dir` config in `lissome`, or `"assets/lustre_app"` if not set
      - `gleam_app` is the `:gleam_app` option or its default value if not provided.
      - `capitalized_type` is the name of the type but with its first character in uppercase.
    * `:gleam_app` - Name of the Gleam application Defaults to the value of `:gleam_app` config in `lissome`, or `"lustre_app"` if not set

  ## Examples

      iex> from_record(:person, :my_gleam_module, %{name: "John", age: 30})
      %GleamType{name: :person, values: %{name: {0, "John"}, age: {1, 30}, __gleam_record__: true}}
  """
  def from_record(type, module, values, opts \\ []) when is_map(values) do
    hrl_file_path =
      opts[:hrl_file_path] ||
        build_hrl_file_path(
          type,
          module,
          opts[:gleam_app] || Utils.gleam_app()
        )

    values =
      type
      |> Record.extract(from: hrl_file_path)
      |> Enum.with_index()
      |> Enum.reduce(%{}, fn {{key, _}, index}, acc ->
        Map.put(acc, key, {index, Map.get(values, key)})
      end)

    %__MODULE__{name: type, values: values, record?: true}
  end

  @doc """
  Converts a GleamType struct to its corresponding Erlang tuple.

  Handles nested GleamTypes structs inside the values, converting them to their Erlang tuples as well.

  If the GleamType was constructed using a record, then this functions
  guarantees that the tuple will have the values in the order Erlang expects them.

  ## Examples

      iex> to_erlang_tuple(%GleamType{name: :point, values: %{x: {0, 1}, y: {1, 2}}})
      {:point, 1, 2}

      iex> to_erlang_tuple(%GleamType{name: :person, values: %{name: {0, "John"}, skill: {1, %GleamType{name: :skill, values: %{name: {0, "coding"}, proficiency: {1, 10}}}}}})
      {:person, "John", {:skill, "coding", 10}}
  """
  def to_erlang_tuple(%__MODULE__{name: name, values: values, record?: record?}) do
    convert_to_erlang_tuple(values, name, record?)
  end

  defp convert_to_erlang_tuple(values, type, true) do
    values
    |> Map.values()
    |> List.keysort(0, :asc)
    |> Enum.map(fn {_, value} -> value end)
    |> convert_to_erlang_tuple(type)
  end

  defp convert_to_erlang_tuple(values, type, _),
    do: convert_to_erlang_tuple(values, type)

  defp convert_to_erlang_tuple(values, type) do
    values =
      case values do
        values when is_list(values) -> values
        _ -> [values]
      end

    values
    |> Enum.map(&convert_value/1)
    |> prepend_type(type)
    |> List.to_tuple()
  end

  defp convert_value(%__MODULE__{} = value), do: to_erlang_tuple(value)
  defp convert_value(value), do: value

  defp build_hrl_file_path(type, module, gleam_app) do
    type_string = type |> Atom.to_string() |> String.capitalize()

    Path.join([
      Utils.gleam_dir_path(),
      "build/dev/erlang",
      gleam_app,
      "include/#{module}_#{type_string}.hrl"
    ])
  end

  defp prepend_type(list, type), do: [type | list]

  @doc """
  Flattens a nested GleamType record structure into a single map.

  Recursively traverses the values and merges nested GleamTypes into a single flat map. This is intended to convert a GleamType struct into a map that can be serialized to JSON.

  ## Examples

      iex> flat_tuple_map(%{name: {0, "John"}, address: {1, %GleamType{name: :address, values: %{city: {0, "NY"}}}}})
      %{name: "John", city: "NY"}
  """
  def flat_tuple_map(values) do
    Enum.reduce(values, %{}, fn
      {_key, {_index, %__MODULE__{values: value}}}, acc ->
        Map.merge(acc, flat_tuple_map(value))

      {key, {_index, value}}, acc ->
        Map.put(acc, key, value)
    end)
  end
end
