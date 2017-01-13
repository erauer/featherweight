defmodule Featherweight.Socket do
  @moduledoc false

  def connect(%{scheme: :mqtt, host: host, port: port, timeout: timeout}) do
    tcp_opts = [:binary, active: true]
    :gen_tcp.connect(String.to_char_list(host), port, tcp_opts, timeout)
  end

   def send(socket, packet) do
     :gen_tcp.send(socket,packet)
   end

   def socket(socket) do
     :gen_tcp.close(socket)
   end

end
