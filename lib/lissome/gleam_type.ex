defmodule Lissome.GleamType do
  @moduledoc """
  Helpers to work with Gleam types and their Erlang representations.

  This module is used to work with Gleam type constructors that take at least one value.
  If you are passing a constructor that takes no values, use the constructor name
  in lowercase as an atom. For example, to pass `None` use `:none`.
  """

  @typedoc """
  The GleamType struct type.
  """
  @type t() :: %__MODULE__{
          name: atom(),
          values: any(),
          record?: boolean()
        }

  defstruct [:name, :values, :record?]

  defimpl JSON.Encoder, for: Lissome.GleamType do
    def encode(%Lissome.GleamType{record?: true} = gleam_type, opts) do
      gleam_type
      |> Lissome.GleamType.flat_values()
      |> JSON.Encoder.Map.encode(opts)
    end

    def encode(%Lissome.GleamType{values: value}, opts) do
      JSON.Encoder.encode(value, opts)
    end
  end

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

  This function only wraps the value with the type name.
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

  Extracts record information from the corresponding .hrl file and builds a GleamType with the
  proper structure. Each field is stored with the index where that field should be in the
  corresponding Erlang tuple.

  ## Options

    * `:hrl_file_path` - Path to the .hrl file where the record is defined. Defaults to `{gleam_dir}/build/dev/erlang/{gleam_app}/{module}_{capitalized_type}.hrl`, where:
      - `gleam_dir` is the value of the `:gleam_dir` option.
      - `gleam_app` is the name of the `:gleam_app` option.
      - `capitalized_type` is the name of the type but with its first character in uppercase.
    * `:gleam_dir` - Path to a Gleam project from where the type is defined. This option is required if the `:hrl_file_path` option is not given.
    * `:gleam_app` - Name of the Gleam application where the type is defined. This option is required if the `:hrl_file_path` option is not given.

  ## Examples

      iex> from_record(:person, :my_gleam_module, %{name: "John", age: 30})
      %GleamType{name: :person, values: %{name: {0, "John"}, age: {1, 30}, record?: true}}
  """
  def from_record(type, module, values, opts \\ []) when is_map(values) do
    hrl_file_path =
      opts[:hrl_file_path] ||
        build_hrl_file_path(
          type,
          module,
          Keyword.fetch!(opts, :gleam_dir),
          Keyword.fetch!(opts, :gleam_app)
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

  If the GleamType was constructed using a record, then this function guarantees
  that the tuple will have the values in the order Erlang expects them.

  ## Examples

      iex> to_erlang_tuple(%GleamType{name: :some, :value})
      {:some, :value}

      iex> to_erlang_tuple(%GleamType{name: :person, values: %{name: {0, "John"}, skill: {1, %GleamType{name: :skill, values: %{name: {0, "coding"}, proficiency: {1, 10}}, record?: true}}}, record?: true})
      {:person, "John", {:skill, "coding", 10}}
  """
  def to_erlang_tuple(%__MODULE__{name: name, values: values, record?: record?}) do
    convert_to_erlang_tuple(values, name, record?)
  end

  defp convert_to_erlang_tuple(values, type, true) do
    values
    |> Map.values()
    |> List.keysort(0, :asc)
    |> Enum.map(fn {_, val} -> convert_value(val) end)
    |> prepend_type(type)
    |> List.to_tuple()
  end

  defp convert_to_erlang_tuple(value, type, _) do
    value
    |> convert_value()
    |> prepend_type(type)
    |> List.to_tuple()
  end

  defp convert_value(%__MODULE__{} = value) do
    to_erlang_tuple(value)
  end

  defp convert_value(value), do: value

  defp prepend_type(value, type), do: [type | List.wrap(value)]

  defp build_hrl_file_path(type, module, gleam_dir, gleam_app) do
    type_string = type |> Atom.to_string() |> String.capitalize()

    Path.join([
      gleam_dir,
      "build/dev/erlang",
      gleam_app,
      "include/#{module}_#{type_string}.hrl"
    ])
  end

  @doc """
  Flattens all values of a `GleamType` struct into a single map.

  This function recursively traverses and flats any `GleamType` struct inside the values.

  This is intended to convert a GleamType struct into a map that can be serialized to JSON.

  ## Examples

      iex> flat_values(%GleamType{name: :shape, values: %{name: {0, "rectangle"}, dimensions: {1, %GleamType{name: :dimensions, values: %{width: {0, 20}, height: {1, 10}}, record?: true}}}, record?: true})
      %{name: "rectangle", dimensions: %{width: 20, height: 10}}
  """
  def flat_values(%__MODULE__{values: values}) do
    Enum.reduce(values, %{}, fn
      {key, {_index, %__MODULE__{record?: true} = gleam_type}}, acc ->
        Map.put(acc, key, flat_values(gleam_type))

      {key, {_index, %__MODULE__{values: value}}}, acc ->
        Map.put(acc, key, value)

      {key, {_index, value}}, acc ->
        Map.put(acc, key, value)
    end)
  end
end
