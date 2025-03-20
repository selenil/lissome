# Changelog

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
