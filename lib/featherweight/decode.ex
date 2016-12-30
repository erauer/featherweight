defmodule Featherweight.Decode do
  @moduledoc false

 require IEx
 alias Featherweight.Protocol

  def decode(<< <<1::4,0::4>>, _rest::binary>> = bytes) do
    Protocol.Connect.decode(bytes)
  end

  def decode(<< 2::4, _flags::4, _remaining::8, _payload::binary>> = bytes) do
    IO.puts("Received CONNACK")
  end

  def decode(<< 3::4, _flags::4, _remaining::8, _payload::binary>> = bytes) do
    IO.puts("Received PUBLISH")
  end

  def decode(<< 4::4, _flags::4, _remaining::8, _payload::binary>> = bytes) do
    IO.puts("Received PUBACK")
  end

  def decode(<< 5::4, _flags::4, _remaining::8, _payload::binary>> = bytes) do
    IO.puts("Received PUBREC")
  end

  def decode(<< 6::4, _flags::4, _remaining::8, _payload::binary>> = bytes) do
    IO.puts("Received PUBREL")
  end

  def decode(<< 7::4, _flags::4, _remaining::8, _payload::binary>> = bytes) do
    IO.puts("Received PUBCOMP")
  end

  def decode(<< 8::4, _flags::4, _remaining::8, _payload::binary>> = bytes) do
    IO.puts("Received SUBSCRIBE")
  end

  def decode(<< 9::4, _flags::4, _remaining::8, _payload::binary>> = bytes) do
    IO.puts("Received SUBACK")
  end

  def decode(<< 10::4, _flags::4, _remaining::8, _payload::binary>> = bytes) do
    IO.puts("Received UNSUBSCRIBE")
  end

  def decode(<< 11::4, _flags::4, _remaining::8, _payload::binary>> = bytes) do
    IO.puts("Received UNSUBACK")
  end

  def decode(<< 12::4, _flags::4, _remaining::8, _payload::binary>> = bytes) do
    IO.puts("Received PINGREQ")
  end

  def decode(<< 13::4, _flags::4, _remaining::8, _payload::binary>> = bytes) do
    IO.puts("Received PINGRESP")
  end

  def decode(<< 14::4, _flags::4, _remaining::8, _payload::binary>> = bytes) do
    IO.puts("Received DISCONNECT")
  end

  def length_prefixed_strings(<<>>, elements) do
    elements
  end

  def length_prefixed_strings(<<length::size(16),remaining::binary>> = payload, elements) do
    if length > 0 do
      <<str::binary-size(length),next::binary>> = remaining
      elements = elements ++ [str]
      length_prefixed_strings(next,elements)
    else
      length_prefixed_strings(remaining,elements)
    end
  end

end
