alias Featherweight.Encode

defmodule Featherweight.Message.PubAck do
  @moduledoc false

  @enforce_keys [:packet_identifier]
  defstruct [:packet_identifier]

  def decode(<< <<4::4,_reserved::4>>,  _remaining_length::size(8),
            packet_identifier::size(16)>>) do
      %__MODULE__{packet_identifier: packet_identifier}
  end

end

defimpl Encode, for: Featherweight.Message.PubAck do

  alias Featherweight.Message.PubAck

  def encode(%PubAck{packet_identifier: packet_identifier}) do
    fixed_header = << 4::4, 0::4 >>
    variable_header = << packet_identifier::size(16)  >>
    remaining_length_header = << :erlang.byte_size(variable_header) :: 8 >>
    fixed_header <> remaining_length_header <> variable_header
  end
end
