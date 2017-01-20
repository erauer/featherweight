defmodule Featherweight.Client do
  @moduledoc """

  This module contains the main MQTT client implementation
  """

  require IEx

  alias Featherweight.Socket
  alias Featherweight.Decode
  alias Featherweight.Message
  alias Featherweight.Encode

  @default_uri "mqtt://127.0.0.1"
  @default_username nil
  @default_password nil

  @default_timeout 5000

  @type uri :: String.t | nil

  @type options :: [
    uri: uri,
    username: Connect.username,
    password: Connect.password,
    timeout: timeout,
    client_identifier: Connect.client_identifier | nil,
    name: String.t
  ]

  @default_state [
            uri: @default_uri,
            username: @default_username,
            password: @default_password,
            timeout: @default_timeout,
            socket: nil,
            mod: nil,
            mod_state: %{}
  ]

  @callback init() :: any

  @callback on_connect(any()) :: any

  @callback on_disconnect(any()) :: any

  @callback on_msg_received(String.t,binary(),any()) :: any

  @callback on_subscribe([{String.t,integer()}],any()) :: any

  @spec random_client_id() :: String.t
  defp random_client_id() do
    valid_chars = "abcdefghijklmnopqrstuvwxyz" <>
                  "ABCDEFGHIJKLMNOPQRSTUVWXYZ" <>
                  "0123456789"
    list = Enum.map(:binary.bin_to_list(:crypto.strong_rand_bytes(23)),
                    fn char -> String.at(valid_chars,
                      rem(char, String.length(valid_chars))) end)

    :binary.list_to_bin(list)
  end

  defp parse(uri) do
    URI.default_port("mqtt",1883)
    URI.default_port("mqtts",8883)
    %{host: host, port: port, scheme: scheme} = URI.parse(uri)
    %{host: host, port: port, scheme: String.to_atom(scheme)}
  end


  @spec start(module, GenServer.args(), GenServer.options()) :: GenServer.on_start
  def start(module,args \\ [], options \\ []) do
    args = Keyword.merge(args,[mod: module])
    case gen_fsm_opts(options) do
      nil -> :gen_fsm.start_link(__MODULE__, args, options)
      other -> :gen_fsm.start_link(other,__MODULE__, args, options)
    end
  end

  @spec start_link(module, GenServer.args(), GenServer.options()) :: GenServer.on_start
  def start_link(module, args \\ [], options \\ []) do
    args = Keyword.merge(args,[mod: module])
    case gen_fsm_opts(options) do
      nil -> :gen_fsm.start_link(__MODULE__, args, options)
      other -> :gen_fsm.start_link(other,__MODULE__, args, options)
    end
  end

  defp gen_fsm_opts(opts) when is_list(opts) do
    case Keyword.pop(opts,:name) do
      {nil,_} -> nil
      {name,_} when is_atom(name) -> {:local,name}
      {val,_} when is_tuple(val) -> val
    end
  end

  def init(args) do
    defaults = Keyword.merge(@default_state, [client_identifier: random_client_id()])
    args =  Keyword.merge(defaults, args, fn (_key,default_val,val) ->
         if val == nil do default_val else val end
    end)

    #Parse URI
    state = Enum.into(args,%{})
    %{uri: uri} = state
    state = Map.merge(state,parse(uri))
    %{mod: module} = state
    :gen_fsm.send_event_after(0,:connect)
    wrap_cb(&module.init/0,[],:connecting,state)
  end

  def disconnect(client) do
    :gen_fsm.send_event(client,%Message.Disconnect{reason: :user_disconnect})
  end

  def publish(client,topic,payload,qos,retain) do
    :gen_fsm.send_event(client,{:send, %Message.Publish{
        topic: topic,
        qos: qos,
        payload: payload,
        retain: retain
      }})
  end

  def subscribe(client,topics) do
    packet_identifier = :crypto.strong_rand_bytes(2)
    :gen_fsm.send_event(client,%Message.Subscribe{packet_identifier: packet_identifier, topics: topics})
  end

  def unsubscribe(client,topics) do
    packet_identifier = :crypto.strong_rand_bytes(2)
    :gen_fsm.send_event(client,%Message.Unsubscribe{packet_identifier: packet_identifier, topics: topics})
  end

  def wrap_cb(func,args,state_name,state) when is_function(func) do
    wrap_cb(apply(func, args),state_name,state)
  end

  def wrap_cb({:ok},state_name,state) do
    {:next_state,state_name,state}
  end

  def wrap_cb({:ok,mod_state},:connecting,state) do
    {:ok,:connecting,%{state | mod_state: mod_state}}
  end

  def wrap_cb({:ok,mod_state},state_name,state) do
    {:next_state,state_name,%{state | mod_state: mod_state}}
  end

  def wrap_cb({:stop,reason,mod_state},_state_name,state) do
    {:stop,reason,state}
  end

  # gen_fsm callbacks

  def connecting(:connect,state) do
    case Socket.connect(state) do
      {:ok, socket} ->
        conn =  Map.merge(%Message.Connect{
                  keep_alive: Map.get(state,:timeout),
                  client_identifier: Map.get(state,:client_identifier)
                },state)
                Socket.send(socket,Encode.encode(conn))
                {:next_state, :connecting, %{state | socket: socket}}
      {:error, reason} ->
        IO.puts "TCP connection error: #{inspect reason}"
        {:error, reason} # try again in one second
    end
  end

  def connecting(%Message.ConnAck{}, %{timeout: timeout, mod: module, mod_state: mod_state} = state) do
    keep_alive = Kernel.round(timeout/3)
    :timer.send_interval(keep_alive,self(),:keep_alive)
    wrap_cb(&module.on_connect/1,[mod_state],:connected,Map.merge(state, %{keep_alive: keep_alive, ping_count: 0}))
  end

  def connected(%Message.Disconnect{reason: _reason}, %{socket: socket} = state) do
      Socket.send(socket,Encode.encode(%Message.Disconnect{}))
      {:next_state, :disconnecting, state}
  end

  def connected(%Message.PingResp{}, state) do
    {:next_state,  :connected, Map.merge(state,
      %{unanswered_ping_count: 0})}
  end


  def connected(%Message.Subscribe{} = message, %{socket: socket} = state) do
     IO.puts("Subscribing")
     Socket.send(socket,Encode.encode(message))
      {:next_state, :connected, state}
  end

  def connected(%Message.Unsubscribe{} = message, %{socket: socket} = state) do
     IO.puts("Unsubscribing")
     Socket.send(socket,Encode.encode(message))
      {:next_state, :connected, state}
  end

  def connected(%Message.SubAck{return_codes: return_codes} = message,
                %{mod: module, mod_state: mod_state} = state) do
      IO.puts(inspect(message))
      wrap_cb(&module.on_subscribe/2,[return_codes,mod_state],:connected,state)
  end

  def connected(%Message.UnsubAck{} = message, state) do
      IO.puts(inspect(message))
      {:next_state, :connected, state}
  end

  # Incoming Publish
  def connected(%Message.Publish{qos: qos, packet_identifier: packet_identifier} = message,
               %{socket: socket, mod: module, mod_state: mod_state} = state) do
   if qos == 1 do
      Socket.send(socket,Encode.encode(%Message.PubAck{packet_identifier: packet_identifier}))
    end
    %{topic: topic, payload: payload} = message
    wrap_cb(&module.on_msg_received/3,[topic,payload,mod_state],:connected,state)
    {:next_state, :connected, state}
  end

  # Outgoing Publish
  def connected({:send, %Message.Publish{} = message}, %{socket: socket} = state) do
     Socket.send(socket,Encode.encode(message))
     {:next_state, :connected, state}
  end

  def handle_info({:tcp_closed, _socket}, state_name,
                                      %{mod: module, mod_state: mod_state} = state) do
    IO.puts("TCP Closed")
    wrap_cb(&module.on_disconnect/1,[mod_state],state_name,state)
  end

  def handle_info({:tcp, _socket, data}, state_name, state) do
    handle_info(Decode.decode(data), state_name, state)
  end

  def handle_info(%{} = message, :connected, state) do
    connected(message,state)
  end

  def handle_info(%{} = message, :connecting, state) do
    connecting(message,state)
  end

  def handle_info(:keep_alive, :connected,
                  %{socket: socket, mod_state: mod_state, mod: module} = state) do
    unanswered_ping_count = Map.get(state,:unanswered_ping_count,0)
    if unanswered_ping_count > 4 do
      Socket.close(socket)
      #wrap_cb(&module.on_disconnect/1,[],state,state)
    else
      Socket.send(socket,Encode.encode(%Message.PingReq{}))
      {:next_state, :connected, Map.merge(state,
          %{unanswered_ping_count: unanswered_ping_count + 1})}
    end
  end

  def terminate(_reason, _state_name, _state) do
    :normal
  end

end
