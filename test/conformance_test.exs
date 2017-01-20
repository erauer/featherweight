defmodule Featherweight.ConformanceTest do

  @moduledoc false

  use ExUnit.Case
  @moduletag :external

  alias Featherweight.TestClient

  test "Client should publish and subscribe" do
    Process.register self, :test

    {:ok, pid} = TestClient.start_link()
    assert_receive :connected

    Featherweight.subscribe(pid,[{"/foo",:qos0}])
    assert_receive {:subscribed,[ok: :qos0]}

    Featherweight.publish(pid,"/foo","hello")
    assert_receive {:received,{"/foo","hello"}}

    Featherweight.disconnect(pid)

    assert_receive :disconnected

  end

  test "Client should support Last Will and Testament" do
    Process.register self, :test
      {:ok, pid1} = TestClient.start_link([will_topic: "a/b",
                    will_message: "Goodbye cruel World!",
                    will_qos: :qos1])
      assert_receive :connected

      {:ok, pid2} = TestClient.start_link()
      assert_receive :connected

      Featherweight.subscribe(pid2,[{"a/b",:qos1}])
      assert_receive {:subscribed,[ok: :qos1]}

      :gen_fsm.stop(pid1)

      assert_receive {:received,{"a/b","Goodbye cruel World!"}}

      Featherweight.disconnect(pid2)
      assert_receive :disconnected

  end


end
