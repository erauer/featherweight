defmodule Featherweight.TestClient do

  @moduledoc false

  use Featherweight

  def start_link(args \\ [], options \\ []) do
    Featherweight.start_link(__MODULE__,args,options)
  end

  def init() do
    {:ok, %{num_msgs_received: 0}}
  end

  def on_connect(state) do
    IO.puts("Connected")
    send :test, :connected
    {:ok,state}
  end

  def on_disconnect(state) do
    IO.puts("Disconnected")
    send :test, :disconnected
    {:stop, :normal, state}
  end

  def on_msg_received(topic,payload,
                      %{num_msgs_received: num_msgs_received} = state) do
    IO.puts("Received Message")
    IO.puts(inspect(payload))
    send :test, {:received, {topic,payload}}
    {:ok,%{state | num_msgs_received: num_msgs_received + 1}}
  end

  def on_subscribe(return_codes,state) do
    IO.puts("Subscribed")
    IO.puts(inspect(return_codes))
    send :test, {:subscribed,return_codes}
    {:ok,state}
  end

end
