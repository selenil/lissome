import gleam/dynamic.{type Dynamic}
import lissome.{type Error, type LiveViewHook, NotABrowser}
import lustre/effect

/// A response from the LiveView in the server to an event
/// pushed from the client.
///
/// This is typically wrapped in a variant of the `Msg` type in a Lustre app.
///
/// ## Examples
///
/// ```gleam
/// pub type Msg {
///   SubmitFormToServer(live_view.LiveViewPushResponse)
/// }
///
/// pub fn update(model, msg) {
///   case msg {
///     SubmitFormToServer(live_view.LiveViewPushResponse(reply, _ref)) -> {
///       // For example, the server could reply with
///       // the result of the form submission
///     }
///   }
/// }
pub type LiveViewPushResponse {
  LiveViewPushResponse(Dynamic, Int)
}

/// Pushes an event to the LiveView running on the server that owns the given
/// hook, using Lustre's effect system.
///
/// The `on_reply` argument must be a type variant that wraps
/// the `live_view.LiveViewPushResponse` type and it will be dispatched to
/// the Lustre runtime *only* if the LiveView on the server respond to the event
/// with a `{:reply, map, socket}` tuple. In that case, both `map` and a
/// reference to the LiveView will be avaliable as fields in the type.
pub fn push_event(
  lv_hook hook: LiveViewHook,
  event evt: String,
  payload p: a,
  on_reply reply_wrapper: fn(LiveViewPushResponse) -> b,
) {
  fn(dispatch) {
    let _ =
      do_push_event(hook, evt, p, fn(reply, ref) {
        reply_wrapper(LiveViewPushResponse(reply, ref)) |> dispatch()
      })

    Nil
  }
  |> effect.from()
}

/// Pushes an event to a LiveView or a LiveComponent running on the server
/// where the result of the given `to` query selector is defined in.
/// If `to` returns more than one element, the event will be dispatched to all
/// of them.
///
/// The `on_reply` argument must be a type variant in your `Msg` type that wraps
/// the `live_view.LiveViewPushResponse` type. This type will be dispatched to
/// the Lustre runtime *only* if the LiveView on the server respond to the event
/// with a `{:reply, map, socket}` tuple. In that case, both `map` and a
/// reference to the LiveView will be avaliable as fields in the type.
pub fn push_event_to(
  lv_hook hook: LiveViewHook,
  to query_selector: String,
  event evt: String,
  payload p: a,
  on_reply reply_wrapper: fn(LiveViewPushResponse) -> b,
) {
  fn(dispatch) {
    let _ =
      do_push_event_to(hook, query_selector, evt, p, fn(reply, ref) {
        reply_wrapper(LiveViewPushResponse(reply, ref)) |> dispatch()
      })

    Nil
  }
  |> effect.from()
}

/// Handles an event pushed from a LiveView running on the server, using Lustre's
/// effect system.
///
/// The `on_reply` argument takes the payload sent by the LiveView on the server
/// as a parameter and returns a message to be dispatched to the Lustre runtime.
pub fn handle_event(
  lv_hook hook: LiveViewHook,
  event evt: String,
  on_reply reply_wrapper: fn(a) -> b,
) {
  fn(dispatch) {
    let _ =
      do_handle_event(hook, evt, fn(payload) {
        reply_wrapper(payload) |> dispatch()
      })

    Nil
  }
  |> effect.from()
}

@external(javascript, "../lissome_ffi.mjs", "pushEvent")
fn do_push_event(
  _hook: LiveViewHook,
  _evt: String,
  _payload: a,
  _on_reply: b,
) -> Result(Nil, Error) {
  Error(NotABrowser)
}

@external(javascript, "../lissome_ffi.mjs", "pushEventTo")
fn do_push_event_to(
  _hook: LiveViewHook,
  _query_selector: String,
  _evt: String,
  _payload: a,
  _on_reply: b,
) -> Result(Nil, Error) {
  Error(NotABrowser)
}

@external(javascript, "../lissome_ffi.mjs", "handleEvent")
fn do_handle_event(
  _hook: LiveViewHook,
  _evt: String,
  _on_reply: b,
) -> Result(Nil, Error) {
  Error(NotABrowser)
}
