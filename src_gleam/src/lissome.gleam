import gleam/dynamic/decode
import gleam/json
import gleam/result

pub type Error {
  NotABrowser
  ElementNotFound(id: String)
  JSONDecodeError(json.DecodeError)
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
