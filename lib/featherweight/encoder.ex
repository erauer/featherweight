defprotocol Featherweight.Encode do
  @doc "Create binary representation of control packet"
  def encode(data)
end
