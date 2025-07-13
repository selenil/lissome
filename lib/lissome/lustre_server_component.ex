defmodule Lissome.LustreServerComponent do
  @moduledoc """
  Module for interacting with Lustre server components.

  Lustre server components are an advanced feature of Lustre where you run a Lustre app
  in the server while sending updates to a client runtime, the Lustre client runtime, implemented as a web
  component. This way all your Gleam code runs on the server, by compiling it to Erlang instead of JavaScript.

  This module provides functions to start, interact and manage Lustre server components,
  but all the network infrastructure the server component will connect to it is up to the developer.
  This design is because Lustre server components are agnostic to the underlying transport layer
  and allow a flexible setup. Since Phoenix already gives you tools to build that infrastructure,
  you can orchestrate your own workflow with server components that better suits the application needs,
  rather than relying on a specific approach.

  ## Using Lustre server components

  To get started with Lustre server components, first you will need to serve a JavaScript client runtime
  which defines a custom web element used for rendering Lustre server components. This comes as a single
  JavaScript file inside the `priv` folder of the `lustre` package (there is also a minified version for
  production usage). The most straightforward way to include it in the your application bundle is to copy
  that file and place it anywhere in your assets folder, commonly in the `my_app_web/assets/vendor` folder,
  then import it in your `app.js`.

  Next, create a Gleam module in your Gleam project that defines a Lustre application and a public
  function that takes no arguments and returns that Lustre application. By convention that function
  is named `component` and it does not need to start the application by calling `lustre.start`,
  as this will be done later.

  Also, be sure your Gleam code is compiled to Erlang when you build your Elixir project. This can be done by
  adding the `:gleam` compiler from Lissome to your list of compilers in the `mix.exs` file:

      def project do
        [
          compilers: Mix.compilers() ++ [:gleam]
        ]
      end

  On the Elixir side, we need a socket to handle the connection between our server component running in the
  server and the Lustre client runtime.

  Create a new module that uses this one:

      defmodule MyAppWeb.MySocket do
        use Lissome.LustreServerComponent
      end

  This will import `Lissome.LustreServerComponent` and inject the behaviour `Phoenix.Socket.Transport`, which
  is a behaviour for a transport layer in Phoenix. With that we can mount the socket in our endpoint:

      # my_app_web/endpoint.ex
      defmodule MyAppWeb.Endpoint do
        ...

        socket "/my-socket", MyAppWeb.MySocket,
          webscoket: true
      end

  From here, we just need to implement the necessary callbacks so our socket can handle properly the server
  component.

  The first step is to start the server component. This is usually done with `start_server_component!/3`
  and `subscribe_to_server_component/2` functions. `start_server_component!/3` will run the server component
  in a separeted process and `subscribe_to_server_component/2` will instruct the server component
  process to send messages to the caller process later on. There are several strategies we can take
  to start server components, depending on their role in the application.

  The common approach is to start an individual server component for each user.

      defmodule MyAppWeb.MySocket do
        use Lissome.LustreServerComponent

        def init(state) do
          # Start a server component for each user
          # server_component is a tuple representing the started process
          server_component = start_server_component!(:my_gleam_module, nil)

          # Subscribe to our server component so this process can
          # start receiving messages from the server component process
          # subject is a tuple that represents this process
          subject = subscribe_to_server_component(server_component)

          # Put server_component and subject in the state
          # because they will be needed later
          state =
            state
            |> Map.put(:server_component, server_component)
            |> Map.put(:subject, subject)

          {:ok, state}
        end
      end

  However, we can also do the opposite and instead start a single server component and share it with all
  users. This could be useful for real-time applications, where every user needs to see the same data
  at the same time.

      defmodule MyAppWeb.MySocket do
        use Lissome.LustreServerComponent
        use Agent

        def start_link(_opts) do
          # start once the server component and store it for later use
          server_component = start_server_component!(:my_gleam_module, nil)
          Agent.start_link(fn -> server_component end,  name: __MODULE__)
        end

        def global_server_component do
          Agent.get(__MODULE__, & &1)
        end

        def connect(state) do
          # This is invoked once per connection
          # All we need to do here is to ensure that the server component is in our state
          {:ok, Map.put_new(state, :server_component, global_server_component())}
        end

        def init(state) do
          # Instead of starting a new server component,
          # we just subscribe to the one we already started
          subject = subscribe_to_server_component(state.server_component)

          # Put subject in the state
          {:ok, Map.put(state, :subject, subject)}
        end
      end

  It is also possible to mix both approaches into an hybrid one, where we start a server component for a group
  of users that need to operate in the same data like, for example, in a collaborative application.

  After subscribing, the process where the server component was started will send us messages whenever the
  client runtime needs to be updated. When those messages arrives, we need to encode them as JSON and forward
  them to the client using our socket. Lissome provides the utilities for this.

      def handle_info({msg, _ref}, state) do
        json =
          msg
          |> encode_client_message()
          |> json_to_string()

        {:push, {:text, json}, state}
      end

  The client runtime will also send JSON messages to communicate the updates that happens in the client.
  In this case, our job is to decode those messages and send it to the server component process.
  Once again, Lissome provides utilities for that.

      def handle_in({msg, _ref}, state) do
        # The Lissome.LustreServerComponent.parse_client_message!/1 function will raise
        # if we pass it a message sent by something other than the Lustre client runtime
        # In this example it's fine because our socket only receives messages
        # from the Lustre client runtime, but if you are connecting
        # other clients using the same socket, you might want to use the non-raise variant
        # `Lissome.LustreServerComponent.parse_client_message/1` instead
        # and pattern match on the result to handle both the
        # success and the error case as needed
        runtime_message = parse_client_message!(msg)
        send_to_server_component(state.component, runtime_message)

        {:ok, state}
      end

  When we start the server component, Lustre will setup a monitor that will clean the server component when its
  parent exits. It is a good practice to manually unsubscribe from the server component at that moment.

      def terminate(_reason, state) do
        unsubscribe_from_server_component(state.server_component)
      end

  Once you setup the socket, the only thing remaining is to render the server component in your template,
  using the `Lissome.LustreServerComponent.render/1` function.

      defmodule MyAppWeb.ServerComponentExampleHTML do
        use MyAppWeb, :html
        alias Lissome.LustreServerComponent

        def my_page(assings) do
          ~H\"\"\"
            <LustreServerComponent.render route="/my-socket/websocket" />
          \"\"\"
        end
      end

  The route attribute tells the component what route connect to and it should be the route
  where you mounted your socket.
  """

  use Phoenix.Component

  alias Lissome.Render

  defmacro __using__(_opts) do
    quote do
      import Lissome.LustreServerComponent
      @behaviour Phoenix.Socket.Transport
    end
  end

  attr(
    :route,
    :string,
    required: true,
    doc: "The route where the server component will connect to",
    examples: ["/my-socket/websocket", "/my-socket/longpoll"]
  )

  attr(
    :method,
    :atom,
    default: :web_socket,
    values: [:web_socket, :server_sent_events, :polling],
    doc: "The transport method used by the server component"
  )

  attr(
    :attributes,
    :list,
    default: [],
    doc: """
      A list of Lustre attributes to pass to the server component. Each Lustre attribute is a tuple of the
      form: {:attribute, 0, attribute_name, attribute_value}, where the last two elements must be binaries.
      Lustre will take each of those tuples and set the corresponding HTML attribute in the server component
      with the specified value.

      Since the two first values of a Lustre attribute tuple are always the same, you can pass a two element
      tuple, containing just the attribute name and the attribute value, and Lissome will convert it to a Lustre attribute tuple.
    """,
    examples: [
      [
        {:attribute, 0, "value", "10"},

        # shortcut for {:attribute, 0, "value", "10"}
        {"value", "10"}
      ]
    ]
  )

  @doc """
  Renders the markup for a Lustre server component
  """
  def render(assigns) do
    %{route: route, method: method, attributes: attributes} = assigns

    attributes =
      process_attributes(attributes)

    attrs =
      [
        :lustre@server_component.route(route),
        :lustre@server_component.method(method)
      ] ++ attributes

    render_code =
      :lustre@server_component.element(attrs, [])
      |> Render.lustre_to_string()

    assigns = assign(assigns, :render_code, render_code)

    ~H"""
     {Phoenix.HTML.raw(@render_code)}
    """
  end

  defp process_attributes(attributes) do
    Enum.map(attributes, fn
      {name, value} when is_binary(name) and is_binary(value) ->
        {:attribute, 0, name, value}

      other ->
        other
    end)
  end

  @doc """
  Starts a Lustre server component

  This functions runs the Gleam module we want to render as a server component in another process.
  Then, multiple clients can connect to it by calling `subscribe_to_server_component/2`.

  Returns `{:ok, server_component}` if the server component is started successfully, where `server_component`
  is a tuple representing the started process, or `{:error, reason}` if not.

  ## Options

    * `:entry_fn`: The function to call from `module` to get the Lustre application that will be rendered.
    Defaults to `:component`.
    * `:flags_type`: The Gleam type of the flags received by the Lustre application that will be rendered,
    or `nil` if the that Lustre app doesn't receives flags. Defaults to `nil`.

  ## Examples

      iex> Lissome.LustreServerComponent.start_server_component(:my_gleam_module, nil)
      {:ok, {:subject, #PID<0.86.0> , #Reference<0.0.0.135>}}
  """
  def start_server_component(module, flags, opts \\ []) do
    Code.ensure_loaded!(module)

    entry_fn = opts[:entry_fn] || :component
    flags_type = opts[:flags_type] || nil

    flags = Render.process_flags(flags, module, flags_type)

    started =
      module
      |> apply(entry_fn, [])
      |> :lustre.start_server_component(flags)

    case started do
      {:ok, _server_component} = success ->
        success

      {:error, _reason} = error ->
        error
    end
  end

  @doc """
  Same as `start_server_component/3`, but raises if there are any error starting the server component
  """
  def start_server_component!(module, flags, opts \\ []) do
    case start_server_component(module, flags, opts) do
      {:ok, server_component} ->
        server_component

      {:error, reason} ->
        raise "Failed to start module #{module} as a Lustre server component: #{inspect(reason)}"
    end
  end

  @doc """
  Subscribes to a Lustre server component.

  The process with `pid` will start receiving messages from the server component process
  indicating diffs to render in the Lustre client runtime. If not `pid` is provided, it will use
  the pid of the calling process (`self/0`).

  Returns a `subject`, which is a tuple representing the process that subscribed to the server component.

  ## Examples

      iex> server_component = Lissome.LustreServerComponent.start_server_component(:my_gleam_module, nil)
      ...> Lissome.LustreServerComponent.subscribe_to_server_component(server_component)
      {:client_registered_subject,
        {:subject, #PID<0.29.0>, #Reference<0.0.0.134>}}}
  """
  def subscribe_to_server_component(server_component, pid \\ nil) do
    # to_register must be a tuple of the form {:subject, pid, ref}
    # to be passed to Lustre's functions
    to_register = {:subject, pid || self(), make_ref()}
    subject = :lustre@server_component.register_subject(to_register)

    :lustre.send(server_component, subject)

    subject
  end

  @doc """
  Unsubcribes a process from a Lustre server component and therefore it will no longer receive updates from it.

  Returns `:ok`.
  """
  def unsubscribe_from_server_component(server_component, subject) do
    subject = :lustre@server_component.deregister_subject(subject)
    :lustre.send(server_component, subject)

    :ok
  end

  @doc """
  Sends a message to a running Lustre server component.

  > #### Expected message format {: .warning}
  > The `:lustre.send/2` function expects a tuple with elements in an specific order
  > (an Erlang record) as the message to sent to the server component.
  > Since internally this function calls `:lustre.send/2`, this will raise
  > if we pass a message that does not follow the correct format.
  > Generally, you should only use this function with decoded client messages
  > that you want to sent to a running Lustre server component, as those match
  > the expected format. If you want to send a message with another shape,
  > instead use `send/2` directly with the `pid` of the server component.

  Returns `nil`.
  """
  def send_to_server_component(server_component, message) when is_tuple(message) do
    :lustre.send(server_component, message)
  end

  @doc """
  Parses a JSON message sent from the Lustre client runtime.

  Returns `{:ok, parsed_data}` if the parsing succeed or `{:error, decode_errors}`
  if there was any errors parsing the json.

  ## Examples

      iex> json = ~S({"kind":1,"path":"2\n2","name":"click","event":{}})
      ...> Lissome.LustreServerComponent.parse_client_message(json)
      {:ok, {:client_dispatched_message, {:event_fired, 1, "2\\n2", "click", %{}}}}

      iex> json = ~S({"other from": "Lustre runtime"})
      {:error, [
        {:decode_error, "Field", "Nothing", ["kind"]},
        {:decode_error, "Field", "Nothing", ["name"]},
        {:decode_error, "Field", "Nothing", ["value"]}
      ]}
  """
  def parse_client_message(json) do
    # The return value of `:lustre@server_component.runtime_message_decoder/0`
    # is know as a decoder in Gleam, but we called transformer here.
    # The actual decoding is performed with `JSON.decode!/1` and the result of
    # that is passed to the transformer function, which will validate that the parsed data
    # follows an specific structure, corresponding to the original Gleam data structure that
    # was compiled to an Erlang record, and return the data in the format
    # Lustre's functions expects it.
    {_, transformer} = :lustre@server_component.runtime_message_decoder()
    {data, errors} = transformer.(JSON.decode!(json))

    case errors do
      [] ->
        {:ok, data}

      [_ | _] ->
        {:error, errors}
    end
  end

  @doc """
  Same as `parse_client_message/1`, but raises if there are any errors decoding the json.

  This function must be used carefully, as it will raise if we pass it a json string that does not come
  from the Lustre client runtime or matches its format.
  """
  def parse_client_message!(json) do
    case parse_client_message(json) do
      {:ok, data} ->
        data

      {:error, decode_errors} ->
        len = length(decode_errors)

        msg = """
          Found #{len} error#{if len > 1, do: "s", else: ""} decoding the JSON message: #{inspect(decode_errors)}
        """

        raise msg
    end
  end

  @doc """
  Encodes a message from the Lustre server component runtime into a JSON charlist.

  This function is usually chained with `json_to_string/1` to turn the charlist
  into a string before sending it to the Lustre client runtime.

  Returns a charlist representing the encoded message.

  ## Examples

      iex> msg = {:reconcile, 1, {:patch, 0, 0, [], []}}
      ...> Lissome.LustreServerComponent.encode_client_message(msg)
      [
        ~c"{",
        [[34, "kind", 34], 58 | "1"],
        [[44, [34, "patch", 34], 58 | "{}"]],
        ~c"}"
      ]
  """
  def encode_client_message(msg) do
    :lustre@server_component.client_message_to_json(msg)
  end

  @doc """
  Converts a JSON charlist into a string.

  Useful for turning JSON enconded data from the Lustre server component runtime
  to a string we can send to the Lustre client runtime.

  ## Examples

      iex> charlist = [
      ...> ~c"{",
      ...> [[34, "kind", 34], 58 | "1"],
      ...> [[44, [34, "patch", 34], 58 | "{}"]],
      ...> ~c"}"
      ...> ]
      ...> Lissome.LustreServerComponent.json_to_string(charlist)
      "{\"kind\":1,\"patch\":{}}"
  """
  def json_to_string(json) when is_binary(json), do: json
  def json_to_string(json) when is_list(json), do: List.to_string(json)
end
