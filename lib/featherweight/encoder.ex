defprotocol Featherweight.Encode do
  @doc "Create binary representation of control packet"
  def encode(data)
end

defmodule Featherweight.Encoder do
  @moduledoc false

  def flag_bit(bool) when is_boolean(bool) do
    if bool, do: 1, else: 0
  end

  def flag_bit(str)  do
      flag_bit(!is_empty?(str))
  end

  def is_empty?(str) when is_nil(str) do
    true
  end

  def is_empty?(str)  do
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
