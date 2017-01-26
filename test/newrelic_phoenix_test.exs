defmodule NewRelicPhoenixTest do
  use ExUnit.Case
  doctest NewRelicPhoenix
  import NewRelicPhoenix
  alias NewRelicPhoenix.Transaction

  defmodule StatmanStub do
    def record_value(label, duration) do
      send(self(), {:record_value, label, duration})
    end
  end

  setup do
    Application.put_env(:newrelic_phoenix, :statman, StatmanStub)
    :ok
  end

  test "start/finish_transaction" do
    start_transaction("test")
    Process.sleep(100)
    t = finish_transaction()
    assert t.name == "test"
    assert_in_delta t.duration, 100_000, 10_000
    assert_received {:record_value, {"test", :total}, n} when n > 100_000
  end

  test "record_segment" do
    start_transaction("test2")
    record_segment({:db, :segment1}, 1_000)
    record_segment({:db, :segment2}, 2_000)
    record_segment({:db, :segment2}, 3_000)
    t = finish_transaction()
    assert [seg2b, seg2a, seg1] = t.finished_segments
    assert seg1.duration  == 1_000
    assert seg2a.duration == 2_000
    assert seg2b.duration == 3_000
    assert_received {:record_value, {"test2", {:db, :segment1}}, 1_000}
    assert_received {:record_value, {"test2", {:db, :segment2}}, 2_000}
    assert_received {:record_value, {"test2", {:db, :segment2}}, 3_000}
  end

  test "start/finish_segment" do
    start_transaction("test3")
    start_segment({:db, :segment})
    Process.sleep(100)
    finish_segment({:db, :segment})
    t = finish_transaction()
    assert_in_delta hd(t.finished_segments).duration, 100_000, 10_000
  end

  test "measure_segment" do
    start_transaction("test4")
    measure_segment {:db, :segment} do
      Process.sleep(100)
    end
    t = finish_transaction()
    assert_in_delta hd(t.finished_segments).duration, 100_000, 10_000
  end

  test "finish transaction not started should not error" do
    assert %Transaction{} = finish_transaction()
  end

  test "start segment when transaction not started should not error" do
    assert %Transaction{} = start_segment({:db, :fail})
  end

  test "finish segment not started not started should not error" do
    assert %Transaction{} = finish_segment({:db, :fail})
  end
end
