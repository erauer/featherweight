alias Featherweight.Encode

defmodule Featherweight.Message.Publish do
  @moduledoc false

  require Featherweight.Decode
  alias Featherweight.Message

  @type t ::%__MODULE__{topic: String.t,
                        qos: Message.qos(),
                        packet_identifier: String.t,
                        payload: binary,
                        dup: boolean(),
                        retain: boolean(),
  }
  defstruct [:dup, :qos, :retain,
            :topic, :packet_identifier, :payload]

  def decode(<< 3::4, dup::1, 0::2, retain::1, _remaining_length::size(8),
            topic_length::size(16), topic::binary-size(topic_length), payload::binary >>) do

    %__MODULE__{qos: :qos0, topic: topic, payload: payload,
                dup: Message.decode_flag(dup),
                retain: Message.decode_flag(retain)}
  end

  def decode(<< 3::4, dup::1, qos::2, retain::1, _remaining_length::size(8),
            topic_length::size(16), topic::binary-size(topic_length),
            packet_identifier::size(16),payload::binary >>) do

              %__MODULE__{qos: Message.decode_qos(qos), topic: topic, payload: payload,
                          dup: Message.decode_flag(dup), packet_identifier: packet_identifier,
                          retain: Message.decode_flag(retain)}
  end

end

defimpl Encode, for: Featherweight.Message.Publish do

  alias Featherweight.Message.Publish
  import Featherweight.Message

  require IEx

  def encode(%Publish{dup: dup, qos: qos, retain: retain,
            topic: topic, packet_identifier: id,
             payload: payload}) do
    fixed_header = << 3::4, encode_flag(dup)::1, encode_qos(qos)::2, encode_flag(retain)::1  >>
    variable_header = <<byte_size(topic)::16>> <> topic <> encode_packet_identifier(qos,id)
    remaining = variable_header <> payload
    fixed_header <> <<:erlang.byte_size(remaining)::8>> <> remaining
  end

  defp encode_packet_identifier(:qos0,_id), do:  <<>>
  defp encode_packet_identifier(_qos,id), do: id


end
