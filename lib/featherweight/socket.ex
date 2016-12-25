defmodule Featherweight.Socket do

  def connect(%{ssl: false, host: host, port: port, timeout: timeout}) do
    tcp_opts = [:binary, active: true]
    :gen_tcp.connect(String.to_char_list(host), port, tcp_opts, timeout)
  end

   def send(socket, packet) do
     :gen_tcp.send(socket,packet)
   end

end
