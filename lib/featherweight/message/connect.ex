alias Featherweight.Encode

defmodule Featherweight.Message.Connect do
  @moduledoc false

  alias Featherweight.Decode
  alias Featherweight.Message

  @type username :: String.t | nil
  @type password :: String.t | nil
  @type client_identifier :: String.t
  @type will_topic :: String.t | nil
  @type will_message :: String.t | nil
  @type will_qos:: Message.qos() | nil

  @type t ::%__MODULE__{client_identifier: client_identifier,
                        username: username,
                        password: password,
                        will_topic: will_topic,
                        will_message: will_message,
                        will_qos: will_qos
  }
  @enforce_keys [:client_identifier, :keep_alive]
  defstruct [:client_identifier,
            :username, :password,
            :will_retain, :will_qos,
            :will_topic, :will_message, :clean_session,
            :keep_alive]

  def decode(<< 1::4, 0::4, _remaining_length::size(8),
              variable_header::binary - size(8),
              keep_alive::size(16), payload::binary>>) do

    << 0::8, 4::8, "MQTT", 4::8,
    <<username_flag::1, password_flag::1, will_retain_flag::1, will_qos::2,
    will_flag::1,clean_session_flag::1,0::1>> >> = variable_header

    clean_session = (clean_session_flag == 1)
    will_retain = (will_retain_flag == 1)

    payload_strings = Decode.length_prefixed_strings(payload,[])

    {%{client_identifier: client_identifier},payload_strings} = parse_flag(%{}, 1, :client_identifier, payload_strings)

    conn = %__MODULE__{client_identifier: client_identifier, keep_alive: keep_alive, clean_session: clean_session}

    conn = case (will_flag) do
      1 ->
        Map.merge(conn,%{will_qos: Message.decode_qos(will_qos), will_retain: will_retain})
      _ ->
        conn
    end
    {conn, payload_strings} = parse_flag(conn, will_flag, :will_topic, payload_strings)
    {conn, payload_strings} = parse_flag(conn, will_flag, :will_message, payload_strings)
    {conn, payload_strings} = parse_flag(conn, username_flag, :username, payload_strings)
    {conn, _payload_strings} =  parse_flag(conn, password_flag, :password, payload_strings)

    conn
  end

  def parse_flag(map, flag, identifier, strings) do
    case flag do
      1 ->
        [value | rest] = strings
        {Map.merge(map,%{identifier => value}), rest}
      0 ->
        {map, strings}
    end
  end

end

defimpl Encode, for: Featherweight.Message.Connect do

  import Featherweight.Message
  alias Featherweight.Message.Connect

  def encode(%Connect{username: username, password: password,
                      will_retain: will_retain,
                      will_qos: will_qos,
                      will_topic: will_topic,
                      will_message: will_message,
                      clean_session: clean_session,
                      keep_alive: keep_alive,
                      client_identifier: client_identifier}) do

    fixed_header = << 1::4, 0::4 >>
    variable_header = <<0::8>>  <>
                      <<4::8>> <>
                      "MQTT" <>
                      <<4::8>>  <>
                      <<encode_flag(username)::1,encode_flag(password)::1,
                      encode_flag(will_retain)::1,encode_qos(will_qos)::2,
                      encode_flag(will_message)::1,
                      encode_flag(clean_session)::1, 0::1  >>
    keepalive_header = <<keep_alive::16>>
    payload = length_prefixed_bytes(client_identifier) <>
              length_prefixed_bytes(will_topic) <>
              length_prefixed_bytes(will_message) <>
              length_prefixed_bytes(username) <>
              length_prefixed_bytes(password)
    remaining = variable_header <> keepalive_header <> payload
    remaining_length_header = << :erlang.byte_size(remaining) :: 8 >>
    fixed_header <> remaining_length_header <> remaining
  end
end
