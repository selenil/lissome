defmodule Lissome.UtilsTest do
  use LissomeCase, async: true
  alias Lissome.Utils

  describe "format_module_name/1" do
    test "converts simple module name" do
      assert Utils.format_module_name("home") == :home
    end

    test "converts nested module path" do
      assert Utils.format_module_name("nested/nested/nested/mod") == :nested@nested@nested@mod
    end
  end

  describe "extract_and_create_record/4" do
    test "creates record tuple with provided values" do
      hrl_file =
        mock_hrl_file("gleam_mock_Flags")

      flags = %{count: 5, name: "John"}

      result =
        Utils.extract_and_create_record(
          "gleam_mock",
          :flags,
          flags,
          hrl_file
        )

      assert result == {:flags, "John", 5}
    end

    test "handles missing values with nil" do
      hrl_file =
        mock_hrl_file("gleam_mock_Flags")

      flags = %{name: "John"}

      result =
        Utils.extract_and_create_record(
          "gleam_mock",
          :flags,
          flags,
          hrl_file
        )

      assert result == {:flags, "John", nil}
    end
  end

  describe "extract_gleam_app_name/1" do
    test "extracts app name from gleam.toml" do
      tmp_dir = System.tmp_dir!() |> Path.join("lissome_test")
      File.mkdir_p!(tmp_dir)

      File.write!(Path.join(tmp_dir, "gleam.toml"), """
      name = "my_app"
      version = "1.0.0"
      """)

      assert Utils.extract_gleam_app_name(tmp_dir) == "my_app"
      File.rm_rf!(tmp_dir)
    end
  end
end
