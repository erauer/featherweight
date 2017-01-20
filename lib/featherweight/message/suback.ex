defmodule Featherweight.Message.SubAck do
  @moduledoc false

  alias Featherweight.Message

  defstruct [:packet_identifier, :return_codes]

  def decode(<< <<9::4,_reserved::4>>,  _remaining_length::size(8),
            packet_identifier::binary-size(2), payload::binary>>) do
      %__MODULE__{packet_identifier: packet_identifier,
                  return_codes: decode_results([],payload)
      }
  end

  def decode_results(results,<<result::binary-size(1),remaining::binary>>) do
    <<error::1,_::5,qos::2>> = result
    status = case {error,qos} do
      {0,qos} -> {:ok,Message.decode_qos(qos)}
      {1,_} -> {:error}
    end
    [status | decode_results(results,remaining)]
  end

  def decode_results(results,<<>>) do
    results
  end



end
