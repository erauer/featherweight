alias Featherweight.Encode

defmodule Featherweight.Protocol.PingReq do
  @moduledoc false

  defstruct []

  def decode(<< 12::4, 0::4, 0::8 >>) do
      %__MODULE__{}
  end


end

defimpl Encode, for: Featherweight.Protocol.PingReq do

  alias Featherweight.Protocol.PingReq

  def encode(%PingReq{}) do
    << 12::4, 0::4, 0::8 >>
  end

end
