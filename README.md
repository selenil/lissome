# Lissome

Lissome is a library to integrate the [Gleam](https://gleam.run/) frontend framework [Lustre](https://hexdocs.pm/lustre/lustre.html) with Phoenix Live View.

> [!WARNING]
> This project is on early stage of development and breaking changes are expected.

## Setup

First, make sure you have the Gleam compiler installed. Instructions can be found [here](https://gleam.run/getting-started/installing/)

1. Add `lissome` to your `mix.exs` file:

```elixir
def deps do
  [
    ...,
    {:lissome, "~> 0.3.0"},
  ]
end
```

then run:

```bash
mix deps.get
```

2. Create a new Gleam project and add Lustre to it. You can create it anywhere, but it is recommended to create it inside the `assets` directory. By default, Lissome will search for a Gleam project in the `assets/lustre_app` directory. If you chose a different name, set the path where you Gleam project lives in the `gleam_dir` config:

```bash
gleam new my_gleam_app

cd my_gleam_app
gleam add lustre
```

```elixir
# config/config.exs

# if you created your Gleam project in a different location than "assets/lustre_app"
config :lissome, :gleam_dir: "my_dir/my_gleam_app"
```

Lissome ships with its own gleam package that contains utilities functions to interop with Phoenix LiveView. You can add it to your Gleam project as a path dependency:

```toml
# gleam.toml

[dependencies]
lissome = { path = "path/to/deps/lissome/src_gleam" }
```

3. Register a hook with the name `LissomeHook` in your `LiveSocket` instance using the `createLissomeHook` function from Lissome. This function takes an object containing the Gleam modules you want to render as an argument. The keys must be the name of the modules, in lowercase, and the values the functions responsables to start the Lustre app in each of those modules (this is typically the `main` function).

```javascript
// app.js
import { createLissomeHook } from "path/to/deps/lissome/assets/lissome.mjs"
import { main as hello_main } from "path/to/my_gleam_project/build/dev/javascript/my_gleam_app/hello.mjs"
import { main as about_main } from "path/to/my_gleam_project/build/dev/javascript/my_gleam_app/pages/about.mjs"

const lustreModules = { hello: hello_main, about: about_main }

let liveSocket = new LiveSocket("/live", Socket, {
  ...,
  hooks: { ..., LissomeHook: createLissomeHook(lustreModules) },
});
```

4. Add the following watcher to your list of watchers in the `config/dev.exs` file and pass it the option `watch: true` to enable live reloading inside your Gleam project during development:

```elixir
# config/dev.exs

config :my_app, MyAppWeb.Endpoint,
  ...,
  watchers: [
    ...,
    gleam: {Lissome.GleamBuilder, :build_gleam, [:javascript, [watch: true]]}
]
```

5. Update your esbuild config to use the `es2020` target:

```elixir
# config.exs

config :esbuild,
  ...,
  my_app: [
    args:
      ~w(js/app.js --bundle --target=es2020 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    ...
  ]
```

6. If you plan to use Tailwind CSS inside your Gleam code, add your gleam files to the content key in the Tailwind CSS config.

```javascript
// tailwind.config.js

module.exports = {
  content: [
    ...,
    "../path/to/my_gleam_app/src/**/*.gleam",
  ],
}
```

## Usage

To render a Lustre app, define a Gleam module with a public function that initializes the app using either the `lustre.simple` or `lustre.application` constructor.

```gleam
//// src/hello.gleam

pub fn init() {
  //...
}

pub fn update(msg, model) {
  //...
}

pub fn view(model) {
  //...
}

pub fn main() {
  let app = lustre.simple(init, update, view)
  let assert Ok(_) = lustre.start(app, "#app", Nil)

  Nil
}
```

Now, inside `HEEX` we can render it using the `.lustre` component:

```elixir
defmodule MyApp.MyLiveView do
  use MyApp, :live_view

  import Lissome.Component

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div>
      <div>Content rendered with Phoenix Live View</div>
      <div>
        <.lustre id="app" name={:hello} />
      </div>
    </div>
    """
  end
end
```

Lissome will encode the flags passed from the server as a json object in a script tag with the id `ls-model`. We can retrieve the flags from Gleam using the `lissome.get_flags` helper:

```gleam
import lissome // <- remember to add this to your project as a path dependency

pub fn main() {
  let decoder = {
    use count <- decode.field("count", decode.int)
    use light_on <- decode.field("light_on", decode.bool)
    decode.success(Model(count, light_on))
  }

  let flags = case lissome.get_flags(id: "ls-model", using: decoder) {
    Ok(flags) -> flags
    Error(_) -> Model(8, True)
  }
}
```

The id of the script tag could be customized by passing to the `id` attribute in the `.lustre` component the value you want.

Check out the project in the `example` directory for a complete code example.

## SSR

Thanks to the ability of Gleam to compile to both Erlang and JavaScript, we can do server-side rendering of Lustre without having to install Node.js. We only need to make sure we compile the Gleam project to Erlang too. For that, add the `:gleam` compiler to your list fo compilers:

```elixir
# mix.exs
def project do
  [
    compilers: Mix.compilers() ++ [:gleam]
  ]
end
```

then update your watcher in `config/dev.exs` to include the `:erlang` target:

```elixir
config :my_app, MyAppWeb.Endpoint,
  ...,
  watchers: [
    ...,
    gleam: {Lissome.GleamBuilder, :build_gleam, [[:javascript, :erlang], [watch: true]]}
]
```

and if the name of your gleam project is different than `"lustre_app"`, register it in the `gleam_app` config:

```elixir
config :lissome, :gleam_app, "my_gleam_app"
```

Now, pass the `ssr={true}` attribute to each `.lustre` component you want to render in the server.

Keep in mind that `Lissome` will call the `init` and the `view` functions of your Gleam module in order to render the initial HTML. By default `Lissome` will look for functions with that name in your module. If you happen to named them differently, you can pass to the `init_fn` attribute the name of your function responsible for initializing the model and to the `view_fn` attribute the name of your function responsible for rendering the view. Both functions must be public.

The type your flags has must be public too. Lissome will use this type to construct the appropriate Erlang record. By default, the expected name for that type is `Model`. If you have a different name, pass to the `flags_type` attribute the name of your type in lowercase.

```elixir
<.lustre
  id="app"
  ssr={true}
  name={:hello}
  init_fn={:my_init_function}
  view_fn={:my_view_function}
  flags_type={:my_flags_type}
/>
```

## Communicating with Phoenix LiveView

`Lissome` includes helpers for communicating with a LiveView running in the server from Gleam code, using [Lustre's effects for managed side effects](https://hexdocs.pm/lustre/guide/03-side-effects.html). To enable this bidirectional communication, you need to construct your app with `lissome.application`. This is a wrapper around `lustre.application` that allows your `init` and `update` function to receive the LiveView hook instance as an argument. This instance could be used to communicate with the server by passing it to the functions in the `lissome/live_view` module.

```gleam
// other imports
import lissome
import lissome/live_view

type Model {
  Model(name: String, email: String)
}

type Msg {
  ServerUpdatedName(String)
  UserUpdatedEmail(String)
  ServerReply(live_view.LiveViewPushResponse)
}

pub fn init(flags, lv_hook: LiveViewHook) {
  let eff = live_view.handle_event(
    lv_hook: lv_hook,
    event: "send-name",
    on_reply: ServerUpdatedName
  )

  #(flags, eff)
}

pub fn update(model, msg, lv_hook: LiveViewHook) {
  case msg {
    ServerUpdatedName(name) -> #(Model(..model, name:), effect.none())
    UserUpdatedEmail(email) -> {
      let eff = live_view.push_event(
        lv_hook: lv_hook,
        event: "update-email",
        payload: email,
        on_reply: Nothing
      )

      #(Model(..model, email:), eff)
    }
    ServerReply(live_view.LiveViewPushResponse(_reply, _ref)) -> #(
      model,
      effect.none(),
    )
  }
}

pub fn view(model) {
  //...
}

pub fn main(hook: LiveViewHook) {
  let flags = Model("John", "jhon@gmail.com")
  let app = lissome.application(init, update, view, hook)
  let assert Ok(_) = lustre.start(app, "#app", flags)

  Nil
}
```

Note that the `hook` instance is passed to your entry function as its only argument. This is done by Lissome when rendering the module.

## Working with Gleam types

When doing SSR, Lissome needs to initialize your app's model by passing the flags as arguments. Since Gleam types are compiled to Erlang tuples, there is a challenge when passing non-primitive types as flags from Elixir because Erlang tuples are not easy serializable to JSON.

To address this, Lissome provides the `Lissome.GleamType` module. This module defines a struct that represent a Gleam type. During SSR, Lissome automatically detects these structs in the flags and converts them to the correct Erlang terms. This conversion happens recursively for any nested `Lissome.GleamType` structs. The `Lissome.GleamType` struct can also be serialized to JSON.

Gleam compiles types constructors that do not have specific fields, like `Ok(a)`, `Error(a)` or `Some(a)`, to a tuple, where the first value is the name of the type constructor as an atom and the second one the value. To represent that kind of types, we can use the `Lissome.GleamType.from_value/2` function:

```elixir
<.lustre
  module={:hello}
  ssr={true}
  flags={name: Lissome.GleamType.from_value(:some, "Jhon")}
>
```

When a type has multiple fields, Gleam compiles it to an [Erlang record](https://www.erlang.org/doc/system/ref_man_records.html). An Erlang record is a tuple where the first element is the name of the type constructor as an atom and the rest elements are the values. Erlang expects the values are in a specific order and includes that information in a `.hrl` file. To represent those types we can use the `Lissome.GleamType.from_record/4` function:

```elixir
<.lustre
  module={:hello}
  ssr={true}
  flags={person: Lissome.GleamType.from_record(
    :person,
    :hello,
    %{name: "Jhon", age: 30}
  )}
>
```

The first argument is the name of the type constructor in lowercase, the second one is the name of the module where that type is defined and the third one is a map with all the values we want to pass to the type constructor.

When the `Lissome.GleamType` struct is encoded to JSON, we get:

- The raw value when the type is not compiled to an Erlang record.
- A map with all types fields and its values when the type is compiled to an Erlang record.

See the `Lissome.GleamType` module in the documentation for more details.

## Roadmap

- [x] Improvements to the SSR.
- [x] Gleam's helpers for communicating with Phoenix LiveView and supporting Lustre's effects.
- [x] Live reload for Gleam.
- [x] Helpers to work with Gleam types and their Erlang representation in Elixir.
- [ ] Support for `lustre.component` constructor.
- [ ] Support for Lustre's `server components`.
- [ ] Support for [`LiveJson`](https://github.com/Miserlou/live_json).
