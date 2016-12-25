defmodule Featherweight.Protocol do

  def parse(<< 1::size(4), 0::size(4), _remaining::size(8)>> = bytes) do
    IO.puts("Received CONNECT")
  end

  def parse(<< 2::size(4), _flags::size(4), _remaining::size(8)>> = bytes) do
    IO.puts("Received CONNACK")
  end

  def parse(<< 3::size(4), _flags::size(4), _remaining::size(8)>> = bytes) do
    IO.puts("Received PUBLISH")
  end

  def parse(<< 4::size(4), _flags::size(4), _remaining::size(8)>> = bytes) do
    IO.puts("Received PUBACK")
  end

  def parse(<< 5::size(4), _flags::size(4), _remaining::size(8)>> = bytes) do
    IO.puts("Received PUBREC")
  end

  def parse(<< 6::size(4), _flags::size(4), _remaining::size(8)>> = bytes) do
    IO.puts("Received PUBREL")
  end

  def parse(<< 7::size(4), _flags::size(4), _remaining::size(8)>> = bytes) do
    IO.puts("Received PUBCOMP")
  end

  def parse(<< 8::size(4), _flags::size(4), _remaining::size(8)>> = bytes) do
    IO.puts("Received SUBSCRIBE")
  end

  def parse(<< 9::size(4), _flags::size(4), _remaining::size(8)>> = bytes) do
    IO.puts("Received SUBACK")
  end

  def parse(<< 10::size(4), _flags::size(4), _remaining::size(8)>> = bytes) do
    IO.puts("Received UNSUBSCRIBE")
  end

  def parse(<< 11::size(4), _flags::size(4), _remaining::size(8)>> = bytes) do
    IO.puts("Received UNSUBACK")
  end

  def parse(<< 12::size(4), _flags::size(4), _remaining::size(8)>> = bytes) do
    IO.puts("Received PINGREQ")
  end

  def parse(<< 13::size(4), _flags::size(4), _remaining::size(8)>> = bytes) do
    IO.puts("Received PINGRESP")
  end

  def parse(<< 14::size(4), _flags::size(4), _remaining::size(8)>> = bytes) do
    IO.puts("Received DISCONNECT")
  end

end
