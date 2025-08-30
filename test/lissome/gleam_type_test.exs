defmodule Lissome.GleamTypeTest do
  use LissomeCase, async: true
  alias Lissome.GleamType

  describe "from_value/2" do
    test "creates a GleamType struct with simple value" do
      result = GleamType.from_value(:some, "hello")
      assert %GleamType{name: :some, values: "hello"} = result
    end

    test "creates a GleamType struct with complex value" do
      value = %{key: "value"}
      result = GleamType.from_value(:complex, value)
      assert %GleamType{name: :complex, values: ^value} = result
    end
  end

  describe "from_record/3" do
    test "creates a GleamType struct from record with proper field indices" do
      hrl_file_path = mock_hrl_file("gleam_mock_Person")

      result =
        GleamType.from_record(
          :person,
          :test_module,
          %{name: "Jhon", age: 30},
          hrl_file_path: hrl_file_path
        )

      assert %GleamType{
               name: :person,
               values: %{
                 name: {0, "Jhon"},
                 age: {1, 30}
               },
               record?: true
             } = result
    end

    test "handles missing values in the input map" do
      hrl_file_path = mock_hrl_file("gleam_mock_Person")

      result =
        GleamType.from_record(:person, :test_module, %{name: "John"},
          hrl_file_path: hrl_file_path
        )

      assert %GleamType{
               name: :person,
               values: %{
                 name: {0, "John"},
                 age: {1, nil}
               },
               record?: true
             } = result
    end
  end

  describe "to_erlang_tuple/1" do
    test "converts simple GleamType to tuple" do
      gleam_type = GleamType.from_value(:some, "hello")
      assert {:some, "hello"} = GleamType.to_erlang_tuple(gleam_type)
    end

    test "converts record GleamType to tuple with proper ordering" do
      hrl_file_path = mock_hrl_file("gleam_mock_Person")

      gleam_type =
        GleamType.from_record(
          :person,
          :test_module,
          %{name: "John", age: 30},
          hrl_file_path: hrl_file_path
        )

      assert {:person, "John", 30} = GleamType.to_erlang_tuple(gleam_type)
    end

    test "handles nested GleamTypes" do
      hrl_file_path = mock_hrl_file("gleam_mock_Person")

      inner_type =
        GleamType.from_record(
          :person,
          :test_modules,
          %{name: "Jhon", age: 30},
          hrl_file_path: hrl_file_path
        )

      gleam_type =
        GleamType.from_record(
          :book,
          :test_module,
          %{title: "Poems", author: inner_type},
          hrl_file_path: hrl_file_path
        )

      assert {:book, "Poems", {:person, "Jhon", 30}} = GleamType.to_erlang_tuple(gleam_type)
    end
  end

  describe "flat_values/1" do
    test "flattens a simple GleamType struct" do
      input = %GleamType{name: :some, values: %{maybe: {0, :not_none}}}
      expected = %{maybe: :not_none}
      assert expected == GleamType.flat_values(input)
    end

    test "handles deeply nested structs" do
      experience = %GleamType{
        name: :experience,
        values: %{
          years: {0, 1},
          location: {1, "some company"}
        },
        record?: true
      }

      skill = %GleamType{
        name: :skill,
        values: %{
          name: {0, :coding},
          level: {1, :expert},
          experience: {2, experience}
        },
        record?: true
      }

      input = %GleamType{
        name: :person,
        values: %{
          name: {0, "John"},
          skill: {1, skill}
        },
        record?: true
      }

      expected = %{
        name: "John",
        skill: %{
          name: :coding,
          level: :expert,
          experience: %{
            years: 1,
            location: "some company"
          }
        }
      }

      assert expected == GleamType.flat_values(input)
    end
  end
end
