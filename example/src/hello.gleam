import gleam/dynamic/decode
import gleam/int
import gleam/json
import lustre
import lustre/attribute
import lustre/element
import lustre/element/html
import lustre/event

pub type Model {
  Model(count: Int, light_on: Bool)
}

pub fn init(flags: Model) -> Model {
  flags
}

pub type Msg {
  Increment
  Decrement
  ToggleLight
}

pub fn update(model: Model, msg: Msg) -> Model {
  case msg {
    Increment -> Model(..model, count: model.count + 1)
    Decrement -> Model(..model, count: model.count - 1)
    ToggleLight -> Model(..model, light_on: !model.light_on)
  }
}

pub fn view(model: Model) {
  let count = int.to_string(model.count)

  html.div(
    [attribute.class("max-w-md mx-auto p-8 bg-white rounded-lg shadow-lg")],
    [
      html.p(
        [attribute.class("text-3xl font-bold text-center text-gray-800 mb-8")],
        [html.text("Gleam ")],
      ),
      html.div(
        [attribute.class("flex items-center justify-center gap-4 mb-8")],
        [
          html.button(
            [
              attribute.class(
                "w-8 h-8 text-center rounded-full bg-gray-200 text-gray-700 text-2xl font-bold hover:bg-gray-300 focus:outline-none focus:ring-2 focus:ring-gray-500 focus:ring-offset-2",
              ),
              event.on_click(Decrement),
            ],
            [element.text("-")],
          ),
          html.div(
            [
              attribute.class(
                "text-4xl font-bold text-gray-700 w-16 text-center",
              ),
            ],
            [element.text(count)],
          ),
          html.button(
            [
              attribute.class(
                "w-8 h-8 text-center rounded-full bg-gray-200 text-gray-700 text-2xl font-bold hover:bg-gray-300 focus:outline-none focus:ring-2 focus:ring-gray-500 focus:ring-offset-2",
              ),
              event.on_click(Increment),
            ],
            [element.text("+")],
          ),
        ],
      ),
      html.div([attribute.class("flex flex-col items-center gap-4")], [
        html.div(
          [
            attribute.class(
              "w-16 h-16 rounded-full flex items-center justify-center transition-colors duration-300 "
              <> case model.light_on {
                True -> "bg-yellow-400 text-gray-900"
                False -> "bg-gray-700 text-white"
              },
            ),
          ],
          [
            case model.light_on {
              True -> html.text("ON")
              False -> html.text("OFF")
            },
          ],
        ),
        html.button(
          [
            attribute.class(
              "px-6 py-2 bg-indigo-600 text-white rounded-md hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:ring-offset-2",
            ),
            event.on_click(ToggleLight),
          ],
          [element.text("Toggle light")],
        ),
      ]),
    ],
  )
}

pub fn main() {
  let json = get_element_by_id("ls-model")
  let flags = parse_flags(json)

  let app = lustre.simple(init, update, view)
  let assert Ok(_) = lustre.start(app, "#app", flags)

  Nil
}

fn parse_flags(json: String) {
  let decoder = {
    use count <- decode.field("count", decode.int)
    use light_on <- decode.field("light_on", decode.bool)
    decode.success(Model(count, light_on))
  }

  case json.parse(from: json, using: decoder) {
    Ok(flags) -> flags
    Error(_) -> Model(8, True)
  }
}

// We don't use `plinth` library here because
// the compilation for Erlang will fail as `plinth`
// doesn't support targets outside Erlang.
// Here we provide an Erlang implementation that just
// panic as this function doesn't have sense outside Javascript
// but this at least allows the compilation to succeed.
// This is not a desired solution, we should find a better.
@external(javascript, "./browser_ffi.mjs", "getElementById")
fn get_element_by_id(_id: String) -> String {
  panic as "Not supported in Erlang"
}
