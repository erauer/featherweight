defmodule Featherweight do

    @moduledoc false

    alias Featherweight.Client

    @spec start_link(module, any, Client.options) :: GenServer.on_start
    def start_link(module, args, options \\ []) do
      Client.start_link(module,args,options)
    end

    defdelegate disconnect(client), to: Client

    defdelegate publish(client,topic,payload,qos \\ :qos0, retain \\ false), to: Client

    defdelegate subscribe(client,topics), to: Client

    defmacro __using__(_) do
      quote location: :keep do
        @behaviour Featherweight.Client

        @doc false
        def on_connect() do
          {:ok}
        end

        def on_disconnect() do
          {:stop, :normal}
        end

        def on_msg_received(topic,payload) do
          {:ok}
        end

        def on_subscribe(return_codes) do
          {:ok}
        end

        defoverridable [
          on_connect: 0,
          on_disconnect: 0,
          on_msg_received: 2,
          on_subscribe: 1
        ]
      end
    end

end
