defmodule Featherweight.Protocol.Publish do
  @moduledoc false

  defstruct [:dup, :qos, :retain,
            :topic_name, :packet_identifier, :payload]

end
