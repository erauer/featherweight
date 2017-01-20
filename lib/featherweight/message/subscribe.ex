alias Featherweight.Encode

defmodule Featherweight.Message.Subscribe do
  @moduledoc false

  alias Featherweight.Message

  @type t ::%__MODULE__{packet_identifier: String.t,
                        topics: [{String.t,Message.qos()}]
  }

  defstruct [:packet_identifier, :topics]

end

defimpl Encode, for: Featherweight.Message.Subscribe do

  alias Featherweight.Message
  alias Featherweight.Message.Subscribe

  def encode(%Subscribe{packet_identifier: packet_identifier, topics: topics}) do
    fixed_header = << 8::4, 2::4 >>
    remaining = packet_identifier <> encode_topics(<<>>,topics)
    fixed_header <> <<:erlang.byte_size(remaining)::8>> <> remaining
  end

  defp encode_topics(payload,[{topic,qos} | tail]) do
    payload = payload <> <<byte_size(topic)::16>> <>
              topic <> <<0::6,Message.encode_qos(qos)::2>>
    encode_topics(payload,tail)
  end

  defp encode_topics(payload, []) do
    payload
  end

end
