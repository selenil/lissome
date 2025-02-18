# Lissome

Lissome is a library to integrate the [Gleam](https://gleam.run/) frontend framework [Lustre](https://hexdocs.pm/lustre/lustre.html) with Phoenix Live View.

> [!WARNING]
> This project is on early stage of development and breaking changes are expected.

## Setup

First, make sure you have the Gleam compiler installed. Instructions can be found [here](https://gleam.run/getting-started/installing/)

1. We will use a tool called `mix_gleam` to manage a Gleam project with Mix. Follow the [instructions](https://github.com/gleam-lang/mix_gleam?tab=readme-ov-file#installation) to setup it.

2. Add `lissome` to your `mix.exs` file:

```elixir
def deps do
  [
    ...,
    {:lissome, "~> 0.2.0"},
  ]
end
```
3. Create a `gleam.toml` file with your Gleam dependencies:

```toml
name = "your_app_name"

[dependencies]
gleam_stdlib = ">= 0.44.0 and < 2.0.0"
lustre = ">= 4.6.3 and < 5.0.0"

[dev-dependencies]
gleeunit = ">= 1.0.0 and < 2.0.0"
```

4. Run:

```bash
mix deps.get
gleam deps download
```

> [!NOTE]
> Although `mix_gleam` is able to install Gleam dependencies, it doesn't manages dependencies well outside Erlang target. For that reason, we usea  `gleam.toml` file and the Gleam tooling to manage Gleam dependencies.

## Usage

To render a Lustre app, we need to define a Gleam module that contains a public `main` function. This function must start a Lustre app created with the `lustre.simple` function.

```gleam
//// src/hello.gleam

pub fn init() {
  ...
}

pub fn update(msg, model) {
  ...
}

pub fn view(model) {
  ...
}

pub fn main() {
  let app = lustre.simple(init, update, view)
  let assert Ok(_) = lustre.start(app, "#app", Nil)

  Nil
}
```

Now, inside `HEEX` we can render it using the `lustre` component:

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
        <.lustre id="app" name="hello" />
      </div>
    </div>
    """
  end
end
```

Check out the project in the `example` directory for a complete code example.

## SSR

Thanks to the ability of Gleam to compile to both Erlang and JavaScript, we can do server-side rendering of Lustre without having to install Node.js. This is why `Lissome` has SSR enabled by default, but you can disable it by passing `ssr={false}` to the `lustre` component.

Keep in mind that `Lissome` will call the `init` and the `view` functions of your Gleam module in order to render the initial HTML. By default `Lissome` will look for functions with that name in your module. If you happen to named them differently, you can pass to the `lustre` component `init_fn` with the name of your function responsible for initializing the model and `view_fn` with the name of your function responsible for rendering the view. Also, both functions must be public.

```elixir
<.lustre
  id="app"
  name="hello"
  init_fn="my_init_function"
  view_fn="my_view_function"
/>
```

## Use cases

In my experience, we should use `Phoenix LiveView` for the most part of the UI Phoenix apps. Even for parts that are heavily interactive, we have ways to build components like modals using JS commands and [perform optimistic updates](https://hexdocs.pm/phoenix_live_view/syncing-changes.html) by combining JS commands and Tailwind CSS classes.

However, there are still parts of the UI that are very complex to implement in `Phoenix LiveView`, often because they have a non-trivial client-side state.

In that situations, we could use Gleam and its fronted framework, Lustre, as they are well suited to handle that kind of state in a simple way. Also, Gleam has interopability with Elixir and both shares many concepts, such as immutability, functional paradigms and pattern matching.

`Lissome` is designed to address *only* the gaps of `Phoenix LiveView` when it comes to client-side state. For the rest of the frontend code, I would suggest keep using `Phoenix LiveView` instead of rewriting the whole UI in Gleam.

## Roadmap

- [ ] Improvements to the SSR.
- [ ] Gleam's helpers for communicating with Phoenix LiveView and supporting Lustre's effects.
- [ ] Hot module replacement for Gleam.
- [ ] Support for [`LiveJson`](https://github.com/Miserlou/live_json).
- [ ] Support for Lustre's `server components`.
