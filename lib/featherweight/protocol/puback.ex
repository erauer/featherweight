alias Featherweight.Encode

defmodule Featherweight.Protocol.PubAck do
  @moduledoc false

  @enforce_keys [:packet_identifier]
  defstruct [:packet_identifier]

end

defimpl Encode, for: Featherweight.Protocol.PubAck do

  import Featherweight.Encoder
  alias Featherweight.Protocol.PubAck

  def encode(%PubAck{packet_identifier: packet_identifier}) do
    fixed_header = << 4::4, 0::4 >>
    variable_header = << packet_identifier::size(16)  >>
    remaining_length_header = << :erlang.byte_size(variable_header) :: 8 >>
    fixed_header <> remaining_length_header <> variable_header
  end
end
