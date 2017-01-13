alias Featherweight.Encode

defmodule Featherweight.Protocol.Subscribe do
  @moduledoc false

  @type t ::%__MODULE__{packet_identifier: String.t,
                        topics: list(tuple())
  }

  defstruct [:packet_identifier, :topics]

end

defimpl Encode, for: Featherweight.Protocol.Subscribe do

  alias Featherweight.Protocol.Subscribe

  def encode(%Subscribe{packet_identifier: packet_identifier, topics: topics}) do
    fixed_header = << 8::4, 2::4 >>
    remaining = packet_identifier <> encode_topics(<<>>,topics)
    fixed_header <> <<:erlang.byte_size(remaining)::8>> <> remaining
  end

  defp encode_topics(payload,[{topic,qos} | tail]) do
    payload = payload <> <<byte_size(topic)::16>> <> topic <> <<0::6,qos::2>>
    encode_topics(payload,tail)
  end

  defp encode_topics(payload, []) do
    payload
  end

end
