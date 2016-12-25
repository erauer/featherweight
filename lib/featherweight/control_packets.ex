defmodule Featherweight.ControlPackets do

  alias Featherweight.Encode
  import Featherweight.Encoder

  defmodule Connect do

    @enforce_keys [:client_identifier]
    defstruct [:client_identifier,
              :username, :password,
              :will_retain, :will_qos,
              :will_topic, :will_message, :clean_session,
              :keep_alive ]
  end

  defimpl Encode, for: Connect do

    def encode(%Connect{username: username, password: password,
                        will_retain: will_retain,
                        will_qos: will_qos,
                        will_topic: will_topic,
                        will_message: will_message,
                        clean_session: clean_session,
                        keep_alive: keep_alive, client_identifier: client_identifier}) do
      will_qos = 0
      fixed_header = << 1::size(4), 0::size(4) >>
      variable_header = <<0::size(8)>>  <>
                        <<4::size(8)>> <>
                        "MQTT" <>
                        <<4::size(8)>>  <>
                        <<flag_bit(username)::1,flag_bit(password)::1,
                        flag_bit(will_retain)::1,0::size(1),
                         0::size(1), flag_bit(will_message)::1,
                          flag_bit(clean_session)::1, 0::size(1)  >>
      keepalive_header = <<keep_alive::size(16)>>
      payload = length_prefixed_bytes(client_identifier) <>
                length_prefixed_bytes(will_topic) <>
                length_prefixed_bytes(will_message) <>
                length_prefixed_bytes(username) <>
                length_prefixed_bytes(password)
      remaining = variable_header <> keepalive_header <> payload
      remaining_length_header = << :erlang.byte_size(remaining) :: size(16) >>
      fixed_header <> remaining_length_header <> remaining
    end
  end

  defmodule ConnAck do

    defstruct [:session_present, :return_code]

  end

  defmodule Publish do

    defstruct [:dup, :qos, :retain,
              :topic_name, :packet_identifier, :payload]

  end

  defmodule PubAck do

    defstruct [:packet_identifier]

  end

  defmodule PubRec do

    defstruct [:packet_identifier]

  end

  defmodule PubRel do

    defstruct [:packet_identifier]

  end

  defmodule PubComp do

    defstruct [:packet_identifier]

  end

  defmodule Subscribe do

    defstruct [:packet_identifier, :topic, :qos]

  end

  defmodule SubAck do

    defstruct [:return_code]

  end

  defmodule Unsubscribe do

    defstruct [:packet_identifier, :topic]

  end

  defmodule UnsubAck do

    defstruct [:packet_identifier]

  end

  defmodule PingReq do

    defstruct []

  end

  defmodule PingResp do

    defstruct []

  end

  defmodule Disconnect do

    defstruct []

  end

end
