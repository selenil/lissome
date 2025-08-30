import lustre
import lustre/attribute.{type Attribute}
import lustre/element.{type Element}
import lustre/element/html
import lustre/event

pub fn register() -> Result(Nil, lustre.Error) {
  let component = lustre.simple(init, update, view)
  lustre.register(component, "light-switch")
}

pub fn element(attributes: List(Attribute(msg))) -> Element(msg) {
  element.element("light-switch", attributes, [])
}

type Model =
  Bool

fn init(_) -> Model {
  True
}

type Msg {
  ToggleLight
}

fn update(model: Model, msg: Msg) -> Model {
  case msg {
    ToggleLight -> !model
  }
}

fn view(model: Model) -> Element(Msg) {
  html.div([attribute.class("flex flex-col items-center gap-4 mt-8")], [
    html.div(
      [
        attribute.class(
          "w-20 h-20 rounded-full flex items-center justify-center text-lg font-medium transition-colors duration-300 "
          <> case model {
            True -> "bg-gleam-400 text-white shadow-lg shadow-gleam-200"
            False -> "bg-gray-200 text-gray-600"
          },
        ),
      ],
      [
        case model {
          True -> html.text("ON")
          False -> html.text("OFF")
        },
      ],
    ),
    html.button(
      [
        attribute.class(
          "px-6 py-3 bg-gleam-500 text-white rounded-lg font-medium hover:bg-gleam-600 transition-colors focus:outline-none focus:ring-2 focus:ring-gleam-400 focus:ring-offset-2",
        ),
        event.on_click(ToggleLight),
      ],
      [element.text("Toggle light")],
    ),
  ])
}
