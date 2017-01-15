alias Featherweight.Encode

defmodule Featherweight.Message.PingReq do
  @moduledoc false

  defstruct []

  def decode(<< 12::4, 0::4, 0::8 >>) do
      %__MODULE__{}
  end


end

defimpl Encode, for: Featherweight.Message.PingReq do

  alias Featherweight.Message.PingReq

  def encode(%PingReq{}) do
    << 12::4, 0::4, 0::8 >>
  end

end
