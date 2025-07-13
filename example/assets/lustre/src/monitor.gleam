import gleam/dynamic
import gleam/dynamic/decode
import gleam/int
import lustre
import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html
import lustre/event

pub type Model {
  Model(
    erlang_version: String,
    atom_count: Int,
    port_count: Int,
    process_count: Int,
    uptime: Int,
    total_memory_usage: Int,
  )
}

pub type Msg {
  UserRequestedReload
}

pub fn component() {
  lustre.simple(init, update, view)
}

pub fn init(_flags) -> Model {
  compute_model()
}

pub fn update(_model: Model, msg: Msg) -> Model {
  case msg {
    UserRequestedReload -> compute_model()
  }
}

pub fn view(model: Model) -> Element(Msg) {
  html.div(
    [
      attribute.class(
        "mx-auto mt-10 p-6 bg-white rounded-xl shadow-md space-y-4",
      ),
    ],
    [
      html.h2(
        [
          attribute.class(
            "text-2xl font-bold text-gray-800 mb-4 flex items-center justify-between",
          ),
        ],
        [
          html.text("BEAM Info"),
          html.button(
            [
              attribute.class("ml-4 p-2 rounded hover:bg-gray-100"),
              attribute.title("Reload"),
              event.on_click(UserRequestedReload),
            ],
            [html.text("🔄")],
          ),
        ],
      ),
      html.dl([attribute.class("divide-y divide-gray-200")], [
        html.div([attribute.class("py-2 flex justify-between")], [
          html.dt([attribute.class("font-medium text-gray-600")], [
            html.text("Erlang Version"),
          ]),
          html.dd([attribute.class("text-gray-900")], [
            html.text(model.erlang_version),
          ]),
        ]),
        html.div([attribute.class("py-2 flex justify-between")], [
          html.dt([attribute.class("font-medium text-gray-600")], [
            html.text("Atoms Count"),
          ]),
          html.dd([attribute.class("text-gray-900")], [
            html.text(int.to_string(model.atom_count)),
          ]),
        ]),
        html.div([attribute.class("py-2 flex justify-between")], [
          html.dt([attribute.class("font-medium text-gray-600")], [
            html.text("Ports Count"),
          ]),
          html.dd([attribute.class("text-gray-900")], [
            html.text(int.to_string(model.port_count)),
          ]),
        ]),
        html.div([attribute.class("py-2 flex justify-between")], [
          html.dt([attribute.class("font-medium text-gray-600")], [
            html.text("Processes Count"),
          ]),
          html.dd([attribute.class("text-gray-900")], [
            html.text(int.to_string(model.process_count)),
          ]),
        ]),
        html.div([attribute.class("py-2 flex justify-between")], [
          html.dt([attribute.class("font-medium text-gray-600")], [
            html.text("Uptime (s)"),
          ]),
          html.dd([attribute.class("text-gray-900")], [
            html.text(int.to_string(model.uptime)),
          ]),
        ]),
        html.div([attribute.class("py-2 flex justify-between")], [
          html.dt([attribute.class("font-medium text-gray-600")], [
            html.text("Total Memory Usage (bytes)"),
          ]),
          html.dd([attribute.class("text-gray-900")], [
            html.text(int.to_string(model.total_memory_usage)),
          ]),
        ]),
      ]),
    ],
  )
}

fn compute_model() -> Model {
  let assert Ok(erlang_version) = decode_to_string(erlang_version())
  let assert Ok(atom_count) = decode_to_int(atom_count())
  let assert Ok(port_count) = decode_to_int(port_count())
  let assert Ok(process_count) = decode_to_int(process_count())
  let assert Ok(uptime) = decode_to_int(uptime())
  let assert Ok(total_memory_usage) = decode_to_int(total_memory_usage())

  Model(
    erlang_version:,
    atom_count:,
    port_count:,
    process_count:,
    uptime:,
    total_memory_usage:,
  )
}

fn decode_to_string(value: dynamic.Dynamic) {
  decode.run(value, decode.string)
}

fn decode_to_int(value: dynamic.Dynamic) {
  decode.run(value, decode.int)
}

@external(erlang, "lissome_ffi", "erlang_version")
fn erlang_version() -> dynamic.Dynamic

@external(erlang, "lissome_ffi", "atoms_count")
fn atom_count() -> dynamic.Dynamic

@external(erlang, "lissome_ffi", "ports_count")
fn port_count() -> dynamic.Dynamic

@external(erlang, "lissome_ffi", "processes_count")
fn process_count() -> dynamic.Dynamic

@external(erlang, "lissome_ffi", "uptime")
fn uptime() -> dynamic.Dynamic

@external(erlang, "lissome_ffi", "total_memory_usage")
fn total_memory_usage() -> dynamic.Dynamic
