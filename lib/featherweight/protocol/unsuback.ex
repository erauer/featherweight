defmodule Featherweight.Protocol.UnsubAck do
  @moduledoc false

  defstruct [:packet_identifier]

  def decode(<< <<11::4,_reserved::4>>,  _remaining_length::size(8),
            packet_identifier::size(16)>>) do
      %__MODULE__{packet_identifier: packet_identifier}
  end

end
