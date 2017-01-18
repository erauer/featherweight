defmodule Featherweight.TestClient do

  @moduledoc false

  use Featherweight

  def start_link(pid, options \\ []) do
    Featherweight.start_link(__MODULE__,pid,options)
  end

  def on_connect() do
    IO.puts("Connected")
    send :test, :connected
    {:ok}
  end

  def on_subscribe(return_codes) do
    IO.puts("Subscribed")
    IO.puts(inspect(return_codes))
    send :test, {:subscribed,return_codes}
    {:ok}
  end

end
