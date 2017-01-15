alias Featherweight.Encode

defmodule Featherweight.Message.Unsubscribe do
  @moduledoc false

  @type t ::%__MODULE__{packet_identifier: String.t,
                        topics: list(String.t)
  }

  defstruct [:packet_identifier, :topics]

end

defimpl Encode, for: Featherweight.Message.Unsubscribe do

  alias Featherweight.Message.Unsubscribe

  def encode(%Unsubscribe{packet_identifier: packet_identifier, topics: topics}) do
    fixed_header = << 10::4, 2::4 >>
    remaining = packet_identifier <> encode_topics(<<>>,topics)
    fixed_header <> <<:erlang.byte_size(remaining)::8>> <> remaining
  end

  defp encode_topics(payload,[topic | tail]) do
    payload = payload <> <<byte_size(topic)::16>> <> topic
    encode_topics(payload,tail)
  end

  defp encode_topics(payload, []) do
    payload
  end

end
