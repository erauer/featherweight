alias Featherweight.Encode

defmodule Featherweight.Protocol.PingResp do
  @moduledoc false

  defstruct []

  def decode(<< 13::4, 0::4, 0::8 >>) do
      %__MODULE__{}
  end


end

defimpl Encode, for: Featherweight.Protocol.PingResp do

  alias Featherweight.Protocol.PingResp

  def encode(%PingResp{}) do
    << 13::4, 0::4, 0::8 >>
  end

end
