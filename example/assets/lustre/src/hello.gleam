import gleam/dynamic
import gleam/dynamic/decode
import gleam/int
import gleam/io
import gleam/option.{type Option, None, Some}
import lissome
import lissome/live_view
import lustre
import lustre/attribute
import lustre/effect
import lustre/element
import lustre/element/html
import lustre/event

const inital_count = 10

pub type Foo {
  Foo(bar: String)
}

pub type Flags {
  Flags(server_count: Option(Int), foo: Foo)
}

pub type Model {
  Model(client_count: Int, server_count: Option(Int), light_on: Bool)
}

pub fn init(flags: Flags, lv_hook: lissome.LiveViewHook) {
  io.debug(flags.foo)
  let model =
    Model(
      client_count: inital_count,
      server_count: flags.server_count,
      light_on: True,
    )

  let effects = [
    live_view.push_event(
      lv_hook:,
      event: "update-client-count",
      payload: model.client_count,
      on_reply: ServerReply,
    ),
    live_view.handle_event(
      lv_hook:,
      event: "update-client-count",
      on_reply: ServerUpdatedCount,
    ),
  ]

  #(model, effect.batch(effects))
}

pub type Msg {
  Increment
  Decrement
  ToggleLight
  ServerUpdatedCount(dynamic.Dynamic)
  ServerReply(live_view.LiveViewPushResponse)
}

pub fn update(model: Model, msg: Msg, lv_hook: lissome.LiveViewHook) {
  case msg {
    Increment -> {
      let count = model.client_count + 1
      #(
        Model(..model, client_count: count),
        update_client_count_effect(lv_hook, count),
      )
    }
    Decrement -> {
      let count = model.client_count - 1
      #(
        Model(..model, client_count: count),
        update_client_count_effect(lv_hook, count),
      )
    }
    ToggleLight -> #(Model(..model, light_on: !model.light_on), effect.none())

    ServerUpdatedCount(count) -> {
      let decoder = {
        use server_count <- decode.field("server_count", decode.int)
        decode.success(server_count)
      }

      let server_count = case decode.run(count, decoder) {
        Ok(count) -> Some(count)
        Error(_) -> None
      }

      #(Model(..model, server_count: server_count), effect.none())
    }
    ServerReply(live_view.LiveViewPushResponse(_reply, _ref)) -> #(
      model,
      effect.none(),
    )
  }
}

pub fn view(model: Model) {
  let client_count = int.to_string(model.client_count)
  let server_count = case model.server_count {
    Some(count) -> int.to_string(count)
    None -> "..."
  }

  html.div([attribute.class("p-8 bg-white rounded-xl shadow-lg md:h-[500px]")], [
    html.h2(
      [attribute.class("text-2xl font-bold text-center text-gray-800 mb-8")],
      [html.text("Gleam Counter")],
    ),
    html.div([attribute.class("flex flex-col items-center gap-8")], [
      html.div(
        [
          attribute.class(
            "flex gap-12 items-center justify-between w-full max-w-md",
          ),
        ],
        [
          html.div([attribute.class("flex flex-col items-center gap-2")], [
            html.div([attribute.class("text-5xl font-bold text-gray-700")], [
              element.text(client_count),
            ]),
            html.div([attribute.class("text-sm text-gray-500 font-medium")], [
              element.text("Client Count"),
            ]),
          ]),
          html.div([attribute.class("flex flex-col items-center gap-2")], [
            html.div([attribute.class("text-5xl font-bold text-gray-700")], [
              element.text(server_count),
            ]),
            html.div([attribute.class("text-sm text-gray-500 font-medium")], [
              element.text("Server Count"),
            ]),
          ]),
        ],
      ),
      html.div([attribute.class("flex gap-4")], [
        html.button(
          [
            attribute.class(
              "w-12 h-12 flex items-center justify-center rounded-full bg-gleam-200 text-gleam-700 text-2xl font-bold hover:bg-gleam-300 transition-colors focus:outline-none focus:ring-2 focus:ring-gleam-500 focus:ring-offset-2",
            ),
            event.on_click(Increment),
          ],
          [element.text("+")],
        ),
        html.button(
          [
            attribute.class(
              "w-12 h-12 flex items-center justify-center rounded-full bg-gleam-200 text-gleam-700 text-2xl font-bold hover:bg-gleam-300 transition-colors focus:outline-none focus:ring-2 focus:ring-gleam-500 focus:ring-offset-2",
            ),
            event.on_click(Decrement),
          ],
          [element.text("-")],
        ),
      ]),
    ]),
    html.div([attribute.class("flex flex-col items-center gap-4 mt-8")], [
      html.div(
        [
          attribute.class(
            "w-20 h-20 rounded-full flex items-center justify-center text-lg font-medium transition-colors duration-300 "
            <> case model.light_on {
              True -> "bg-gleam-400 text-white shadow-lg shadow-gleam-200"
              False -> "bg-gray-200 text-gray-600"
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
            "px-6 py-3 bg-gleam-500 text-white rounded-lg font-medium hover:bg-gleam-600 transition-colors focus:outline-none focus:ring-2 focus:ring-gleam-400 focus:ring-offset-2",
          ),
          event.on_click(ToggleLight),
        ],
        [element.text("Toggle light")],
      ),
    ]),
  ])
}

pub fn main(hook: lissome.LiveViewHook) {
  let decoder = {
    use server_count <- decode.field("server_count", decode.int)
    use foo <- decode.field("foo", {
      use bar <- decode.field("bar", decode.string)
      decode.success(Foo(bar: bar))
    })

    decode.success(Flags(server_count: Some(server_count), foo: foo))
  }

  let flags = case lissome.get_flags(id: "ls-model", using: decoder) {
    Ok(flags) -> flags
    Error(_) -> Flags(server_count: None, foo: Foo("foobar"))
  }

  let app = lissome.application(init, update, view, hook)
  let assert Ok(_) = lustre.start(app, "#app", flags)

  Nil
}

fn update_client_count_effect(lv_hook: lissome.LiveViewHook, count: Int) {
  live_view.push_event(
    lv_hook:,
    event: "update-client-count",
    payload: count,
    on_reply: ServerReply,
  )
}
