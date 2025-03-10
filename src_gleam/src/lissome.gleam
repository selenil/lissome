import gleam/dynamic/decode
import gleam/json
import gleam/result
import lustre
import lustre/effect
import lustre/element

pub type Error {
  NotABrowser
  ElementNotFound(id: String)
  JSONDecodeError(json.DecodeError)
}

/// A Phoenix LiveView hook instance. The hook instance contains
/// methods to communicate with a running LiveView in the server.
pub type LiveViewHook

/// A complete Lustre application that can communicate with Phoenix LiveView
/// over a websocket connection.
///
/// This is a convenience wrapper around `lustre.application` to make the
/// Phoenix LiveView's hook instance available to the `init` and `update`
/// functions as their last argument. Lissome will pass the hook instance to
/// the function that starts your lustre application as its only argument,
/// typically this is the `main` function.
pub fn application(
  init: fn(a, LiveViewHook) -> #(b, effect.Effect(c)),
  update: fn(b, c, LiveViewHook) -> #(b, effect.Effect(c)),
  view: fn(b) -> element.Element(c),
  hook: LiveViewHook,
) -> lustre.App(a, b, c) {
  let lissome_init = fn(model) { init(model, hook) }
  let lissome_update = fn(model, msg) { update(model, msg, hook) }

  lustre.application(lissome_init, lissome_update, view)
}

/// Retrieves and decodes JSON-encoded flags from a DOM element.
///
/// This is particularly useful in server-side rendering (SSR) scenarios,
/// where the flags required to reconstruct the initial model and hydrate
/// the client are encoded in the HTML returned from the server.
pub fn get_flags(
  id el_id: String,
  using decoder: decode.Decoder(a),
) -> Result(a, Error) {
  use json_string <- result.try(get_element_text_by_id(el_id))

  case json.parse(from: json_string, using: decoder) {
    Ok(flags) -> Ok(flags)
    Error(error) -> Error(JSONDecodeError(error))
  }
}

@external(javascript, "./lissome_ffi.mjs", "getElementTextById")
fn get_element_text_by_id(_id: String) -> Result(String, Error) {
  Error(NotABrowser)
}
