defmodule Featherweight.Message.ConnectTest do

  @moduledoc false

  use ExUnit.Case

  require IEx

  alias Featherweight.Message.Connect
  alias Featherweight.Encode
  alias Featherweight.Decode

  test "Connect encoding and decoding should support all flags" do
    conn = %Connect{
      username: "username",
      password: "password",
      will_qos: :qos0,
      will_topic: "will_topic",
      will_message: "will_message",
      will_retain: false,
      client_identifier: "client_identifier",
      keep_alive: 60,
      clean_session: true
    }

    encoded =  Encode.encode(conn)
    decoded =  Decode.decode(encoded)


    ^decoded = conn
  end


end
