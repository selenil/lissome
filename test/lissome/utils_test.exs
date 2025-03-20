defmodule Lissome.UtilsTest do
  use LissomeCase, async: true
  alias Lissome.Utils

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
