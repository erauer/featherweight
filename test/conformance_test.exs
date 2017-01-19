defmodule Featherweight.ConformanceTest do

  @moduledoc false

  use ExUnit.Case
  @moduletag :external

  alias Featherweight.TestClient

  test "Client should publish and subscribe" do
    Process.register self, :test

    {:ok, pid} = TestClient.start_link(self)
    assert_receive :connected

    Featherweight.subscribe(pid,[{"/foo",0}])
    assert_receive {:subscribed,[ok: 0]}

    Featherweight.publish(pid,"/foo","hello")
    assert_receive {:received,{"/foo","hello"}}

    Featherweight.disconnect(pid)

    assert_receive :disconnected

  end


end
