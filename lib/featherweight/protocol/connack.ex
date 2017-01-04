alias Featherweight.Encode

defmodule Featherweight.Protocol.ConnAck do
  @moduledoc false

  defstruct [:session_present, :return_code]

  def decode(<< 2::4, 0::4, _remaining_length::size(8),
              variable_header::binary-size(2) >>) do
        << 0::7, session_present::1, return_code::8 >> =  variable_header
        %__MODULE__{session_present: session_present, return_code: return_code}
  end

end

defimpl Encode, for: Featherweight.Protocol.ConnAck do

  alias Featherweight.Protocol.ConnAck

  def encode(%ConnAck{session_present: session_present, return_code: return_code}) do
    fixed_header = << 2::4, 0::4 >>
    variable_header = << 0::7, session_present::1>> <> <<return_code>>
    remaining_length_header = << :erlang.byte_size(variable_header) :: 8 >>
    fixed_header <> remaining_length_header <> variable_header
  end

end
