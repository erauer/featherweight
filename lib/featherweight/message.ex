defmodule Featherweight.Message do

  @moduledoc false

  @type qos :: :qos0 | :qos1 | :qos2

  def encode_flag(bool) when is_boolean(bool) do
    if bool, do: 1, else: 0
  end

  @spec encode_flag(boolean() | String.t) :: integer()
  def encode_flag(true), do: 1
  def encode_flag(false), do: 0
  def encode_flag(str), do: encode_flag(!is_empty?(str))

  @spec decode_flag(integer()) :: boolean()
  def decode_flag(0), do: false
  def decode_flag(1), do: true

  @spec encode_qos(qos | nil) :: integer()
  def encode_qos(nil), do: 0
  def encode_qos(:qos0), do: 0
  def encode_qos(:qos1), do: 1
  def encode_qos(:qos2), do: 2

  @spec decode_qos(0 | 1 | 2) :: qos()
  def decode_qos(0), do: :qos0
  def decode_qos(1), do: :qos1
  def decode_qos(2), do: :qos2

  defp is_empty?(str) when is_nil(str), do: true

  defp is_empty?(str)  do
    str
    |> String.trim
    |> String.length == 0
  end

  def length_prefixed_bytes(str) do
    case is_empty?(str) do
      true -> <<>>
      false -> <<String.length(str)::16>> <> str
    end
  end

end
