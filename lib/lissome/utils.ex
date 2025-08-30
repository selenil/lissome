defmodule Lissome.Utils do
  @gleam_dir Application.compile_env(:lissome, :gleam_dir)

  gleam_app =
    if @gleam_dir && File.exists?(@gleam_dir) do
      case System.cmd(
             "gleam",
             ~W(export package-information --out /dev/stdout),
             cd: @gleam_dir,
             stderr_to_stdout: true
           ) do
        {output, 0} ->
          output
          |> JSON.decode!()
          |> Map.fetch!("gleam.toml")
          |> Map.fetch!("name")

        # export package-information is not available in the Gleam installation being used
        # fallback to a regex approach
        {_, 2} ->
          toml = File.read!(Path.join(@gleam_dir, "gleam.toml"))

          Regex.run(~r/name\s*=\s*"([^"]+)"/, toml, capture: :all_but_first)
          |> List.first()
      end
    else
      nil
    end

  @gleam_app gleam_app

  @doc "Returns the directory to the configured Gleam project"
  def gleam_dir_path do
    @gleam_dir
  end

  @doc "Returns the app name of the configured Gleam project"
  def gleam_app do
    @gleam_app
  end
end
