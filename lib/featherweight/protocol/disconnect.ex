alias Featherweight.Encode

defmodule Featherweight.Protocol.Disconnect do
  @moduledoc false

  @type reason :: :ping_timeout | :server_disconnect | :user_disconnect
  @type t ::%__MODULE__{reason: reason}
  defstruct [:reason]

  def decode(<< 14::4, 0::4, 0::8 >>) do
      %__MODULE__{}
  end


end

defimpl Encode, for: Featherweight.Protocol.Disconnect do

  alias Featherweight.Protocol.Disconnect

  def encode(%Disconnect{}) do
    << 14::4, 0::4, 0::8 >>
  end

end
