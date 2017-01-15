defmodule Featherweight.Message.ConnAckTest do

  @moduledoc false

  use ExUnit.Case

  alias Featherweight.Message.ConnAck
  alias Featherweight.Encode
  alias Featherweight.Decode

  test "ConnAck decoding should match encoded message" do
    conn_ack = %ConnAck{
      session_present: 1,
      return_code: 0
    }

    encoded =  Encode.encode(conn_ack)
    decoded =  Decode.decode(encoded)

    IO.puts(inspect(decoded))

    ^decoded = conn_ack
  end


end
