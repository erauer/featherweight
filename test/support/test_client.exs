defmodule Featherweight.TestClient do

  @moduledoc false

  use Featherweight

  def start_link(args \\ [], options \\ []) do
    Featherweight.start_link(__MODULE__,args,options)
  end

  def on_connect() do
    IO.puts("Connected")
    send :test, :connected
    {:ok}
  end

  def on_disconnect() do
    IO.puts("Disconnected")
    send :test, :disconnected
    {:ok}
  end

  def on_msg_received(topic,payload) do
    IO.puts("Received Message")
    IO.puts(inspect(payload))
    send :test, {:received, {topic,payload}}
    {:ok}
  end

  def on_subscribe(return_codes) do
    IO.puts("Subscribed")
    IO.puts(inspect(return_codes))
    send :test, {:subscribed,return_codes}
    {:ok}
  end

end
