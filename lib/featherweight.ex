defmodule Featherweight do
  @moduledoc """

  This module contains the main MQTT client implementation
  """

  alias Featherweight.Socket
  alias Featherweight.Decode
  alias Featherweight.Protocol.Connect
  alias Featherweight.Protocol.ConnAck
  alias Featherweight.Protocol.PingReq
  alias Featherweight.Protocol.PingResp
  alias Featherweight.Protocol.Disconnect
  alias Featherweight.Protocol.Subscribe
  alias Featherweight.Protocol.SubAck
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

  @default_args [uri: @default_uri,
            username: @default_username, password: @default_password,
            timeout: @default_timeout]


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


  @spec start_link(options() | keyword()) :: GenServer.on_start
  def start_link(options \\ []) do

   defaults = Keyword.merge(@default_args, [client_identifier: random_client_id()])
   options =  Keyword.merge(defaults, options, fn (_key,default_val,val) ->
        if val == nil do default_val else val end
      end)

    args = Enum.into(options, %{socket: nil})

    #Parse URI
    %{uri: uri} = args
    args = Map.merge(args,parse(uri))

    :gen_fsm.start_link(__MODULE__, args, [])
  end

  def init(args) do
    IO.puts(inspect(args))
    case Socket.connect(args) do
      {:ok, socket} ->
        conn =  Map.merge(%Connect{
                    keep_alive: Map.get(args,:timeout),
                    client_identifier: Map.get(args,:client_identifier)
                  },args)
        Socket.send(socket,Encode.encode(conn))

        {:ok, :connecting, %{args | socket: socket}}
      {:error, reason} ->
        IO.puts "TCP connection error: #{inspect reason}"
        {:error, reason} # try again in one second
    end
  end


  def subscribe(client,topics) do
    packet_identifier = :crypto.strong_rand_bytes(2)
    :gen_fsm.send_event(client,%Subscribe{packet_identifier: packet_identifier, topics: topics})
  end

  def disconnect(client) do
    :gen_fsm.send_event(client,%Disconnect{reason: :user_disconnect})
  end

  # gen_fsm callbacks

  def connected(%Disconnect{reason: _reason}, %{socket: socket} = state_data) do
      Socket.send(socket,Encode.encode(%Disconnect{}))
      {:next_state, :disconnecting, state_data}
  end

  def connected(%PingResp{}, state_data) do
    IO.puts("Ping Response")
    {:next_state,  :connected, Map.merge(state_data,
      %{unanswered_ping_count: 0})}
  end

  def connected(%Subscribe{} = message, %{socket: socket} = state_data) do
     IO.puts("Subscribing")
     Socket.send(socket,Encode.encode(message))
      {:next_state, :connected, state_data}
  end

  def connected(%SubAck{} = message, %{socket: socket} = state_data) do
      IO.puts(inspect(message))
      {:next_state, :connected, state_data}
  end

  def connecting(%ConnAck{}, %{timeout: timeout} = state_data) do
    keep_alive = Kernel.round(timeout/3)
    :timer.send_interval(keep_alive,self(),:keep_alive)
    {:next_state, :connected, Map.merge(state_data, %{keep_alive: keep_alive, ping_count: 0})}
  end

  def handle_info({:tcp_closed, _socket}, _state, state_data) do
    IO.puts("TCP Closed")
    {:stop, :server_disconnect, Map.merge(state_data,%{socket: nil})}
  end

  def handle_info({:tcp, _socket, data}, state_name, state_data) do
    IO.puts("Data Received")
    handle_info(Decode.decode(data), state_name, state_data)
  end

  def handle_info(%{} = message, :connected, state_data) do
    connected(message,state_data)
  end

  def handle_info(%{} = message, :connecting, state_data) do
    connecting(message,state_data)
  end

  def handle_info(:keep_alive, :connected, %{socket: socket} = state_data) do
    unanswered_ping_count = Map.get(state_data,:unanswered_ping_count,0)
    if unanswered_ping_count > 4 do
      {:stop, %Disconnect{reason: :ping_timeout}, state_data}
    else
      Socket.send(socket,Encode.encode(%PingReq{}))
      {:next_state, :connected, Map.merge(state_data,
          %{unanswered_ping_count: unanswered_ping_count + 1})}
    end
  end

  def terminate(_reason, _state, _state_data) do
    :normal
  end

end
