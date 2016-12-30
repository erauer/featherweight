defmodule Featherweight do
  @moduledoc """

  This module contains the main MQTT client implementation
  """

  require IEx

  use Connection

  alias Featherweight.Socket
  alias Featherweight.Decode
  alias Featherweight.Protocol.Connect
  alias Featherweight.Encode

  @default_port 1883
  @default_host "127.0.0.1"
  @default_username nil
  @default_password nil

  @default_timeout 5000

  @type mqtt_port :: number
  @type host :: String.t
  @type username :: String.t | nil
  @type password :: String.t | nil

  @type options :: %{
    port: mqtt_port,
    host: host,
    username: username,
    password: password,
    timeout: timeout
  }

  @type start_link :: {:ok, pid} | {:error, term}

  @spec start_link(options) :: start_link
  def start_link(options \\ %{}) do
    args = %{port: Map.get(options, :port, @default_port),
            host: Map.get(options, :host, @default_host),
            username: Map.get(options, :username, @default_username),
            password: Map.get(options, :password,  @default_password),
            timeout: Map.get(options, :timeout,  @default_timeout),
            socket: nil}
    Connection.start_link(__MODULE__, args)
  end

  def init(state) do
    {:connect, nil, state}
  end

  def connect(_info, %{host: host, port: port, timeout: timeout} = state) do
    case Socket.connect(Map.merge(state,%{ssl: false})) do
      {:ok, socket} ->
        Socket.send(socket, Encode.encode(%Connect{
          keep_alive: 60,
          client_identifier: "foo"
        }))
        {:ok, %{state | socket: socket}}
      {:error, reason} ->
        IO.puts "TCP connection error: #{inspect reason}"
        {:error, reason} # try again in one second
    end
  end

  # GenServer callbacks

  def handle_info({:tcp, _socket, data}, state) do
    IO.puts("Data Received")
    IO.puts(inspect(Decode.decode(data)))
    {:noreply, state}
  end

  def handle_info({:tcp_closed, _socket}, state) do
    IO.puts("TCP Closed")
    {:stop, :shutdown, state}
  end

end
