defmodule Featherweight.Protocol.Publish do
  @moduledoc false

  require IEx

  defstruct [:dup, :qos, :retain,
            :topic, :packet_identifier, :payload]

  def decode(<< 3::4, dup::1, 0::2, retain::1, _remaining_length::size(8),
            topic_length::size(16), topic::binary-size(topic_length), payload::binary >>) do

    %__MODULE__{dup: dup, qos: 0, retain: retain, topic: topic, payload: payload}
  end

  def decode(<< 3::4, dup::1, qos::2, retain::1, _remaining_length::size(8),
            topic_length::size(16), topic::binary-size(topic_length),
            packet_identifier::size(16),payload::binary >>) do

    %__MODULE__{dup: dup, qos: qos, retain: retain, topic: topic,
                packet_identifier: packet_identifier, payload: payload}
  end

end
