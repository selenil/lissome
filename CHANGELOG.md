# Changelog

## v.0.4.0

- Add support for rendering [Lustre server component](https://hexdocs.pm/lustre/lustre/server_component.html). This is a done via a new module, `Lissome.LustreServerComponent`, which provides functions needed for setup, start and interactive with those components. 
- Update Lustre to `5.0.2`. 
- Refactor code towards a more stable API. Changes include:
  - Instead of having users to pass the `main` function of their Gleam modules to the `createLissomeHook`, they just have to pass the entire module now and Lissome will look for the name of the function that starts the app in the `data-entryfn` attribute. This attribute can be set by the user in the Phoenix component, and defaults to `"main"`.
  - The `Lissome.Render` module was renamed to `Lissome.Lustre` and its function to: 
    - `render_lustre/3` -> `render/3`
    - `ssr_lustre/3` -> `server_render/3`
    - `lustre_to_string/1` -> `element_to_string/1`
  - Now the `process_flags/4` function, if the `flags_type` argument is `nil`, returns the flags passed unchanged, unless the flags is a `Lissome.GleamType` struct, in that case it returns `Lissome.GleamType.to_erlang_tuple(flags)`. 
  - Changed `.lustre` component to accept any type of flags, not just maps.
  - Renamed `Lissome.GleamType.flat_tuple_map/1` to `Lissome.GleamType.flat_values/1`.
  - Change the example project to render a part of its Gleam UI using a [Lustre client component](https://hexdocs.pm/lustre/lustre/component.html), to show how they can be rendered inside a Lustre application that in turns is rendered by Lissome.
  - Removed the `Lissome.Utils.json/1` and `Lissome.Utils.extract_gleam_app/1` functions.
  - Changed how we deal with configurations. Now users have to specify in the `:gleam_dir` config where their Gleam project is located and that config does not longer defaults to `"assets/lustre_app"`. Users do not have to use the `:gleam_app` config now, since that value will be extracted automatically at compile time by the library.
  - Changed the server component example FFI in the example project to be written with Elixir, instead of Erlang.
  - Various code and documentation quality improvements.
- Test quality improved and some redundant tests removed.
- 

## v.0.3.0

- Complete redesign of the setup process and the integration with Mix in favor of a more solid approach. We do not use `mix_gleam` anymore and instead we rely on our own system to build and load Gleam code using Mix and the available tooling in Phoenix projects.
- The `Lissome.Component.lustre/1` now support more attributes to integrate better with the new setup process.
- Add a Javascript hook, `LissomeHook`, which serves as an entrypoint to render compiled Gleam code.
- Add a `Lissome.GleamBuilder` module, which wraps the `gleam build` command and offers customization about how the Gleam code is built.
- Add a `Lissome.GleamReloader` module to watch for changes inside a Gleam project and trigger a recompile.
- Add a `Lissome.GleamType` module to represent and interoperate with Gleam types in Elixir. This module provides helpers to convert Gleam types to its Erlang representation and also make them serializable to JSON.
- Add the `lissome.build_gleam` task to build Gleam code using Mix.
- Add the `compile.gleam` task to compile Gleam code to BEAM files using Mix.
- Add a gleam library integrated with `Lissome`, which provides helpers to communicate with Phoenix LiveView running in the server from Gleam code.
- Remove `Lissome.Utils.format_module_name/1`.
- Internal refactor.

## v0.2.0

- Support for Gleam to JavaScript compilation and bundling with Esbuild via `mix compile.gleam_js` task.
- Initial integration between Lustre's apps and Phoenix LiveView through `Lissome.Component.lustre/1`
