defmodule Featherweight do

    @moduledoc false

    alias Featherweight.Client


    @spec start(module, Client.options, GenServer.options) :: GenServer.on_start
    def start(module, args, options \\ []) do
      Client.start(module,args,options)
    end

    @spec start_link(module, Client.options, GenServer.options) :: GenServer.on_start
    def start_link(module, args, options \\ []) do
      Client.start_link(module,args,options)
    end

    defdelegate disconnect(client), to: Client

    defdelegate publish(client,topic,payload,qos \\ :qos0, retain \\ false), to: Client

    defdelegate subscribe(client,topics), to: Client

    defmacro __using__(_) do
      quote location: :keep do
        @behaviour Featherweight.Client

        def init() do
          {:ok,%{}}
        end

        @doc false
        def on_connect(state) do
          {:ok,state}
        end

        def on_disconnect(state) do
          {:stop, :normal}
        end

        def on_msg_received(topic,payload,state) do
          {:ok,state}
        end

        def on_subscribe(return_codes,state) do
          {:ok,state}
        end

        defoverridable [
          init: 0,  
          on_connect: 1,
          on_disconnect: 1,
          on_msg_received: 3,
          on_subscribe: 2
        ]
      end
    end

end
