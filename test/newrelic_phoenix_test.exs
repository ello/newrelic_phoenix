defmodule NewRelicPhoenixTest do
  use ExUnit.Case
  doctest NewRelicPhoenix
  import NewRelicPhoenix

  test "start/finish_transaction" do
    start_transaction("test")
    Process.sleep(100)
    t = finish_transaction()
    assert t.name == "test"
    assert_in_delta t.duration, 100_000, 10_000
  end

  test "record_segment" do
    start_transaction("test2")
    record_segment({:db, :segment1}, 1_000)
    record_segment({:db, :segment2}, 2_000)
    t = finish_transaction()
    assert t.segments[{:db, :segment1}].duration == 1_000
    assert t.segments[{:db, :segment2}].duration == 2_000
  end

  test "start/finish_segment" do
    start_transaction("test3")
    start_segment({:db, :segment})
    Process.sleep(100)
    finish_segment({:db, :segment})
    t = finish_transaction()
    assert_in_delta t.segments[{:db, :segment}].duration, 100_000, 10_000
  end

  test "measure_segment" do
    start_transaction("test4")
    measure_segment {:db, :segment} do
      Process.sleep(100)
    end
    t = finish_transaction()
    assert_in_delta t.segments[{:db, :segment}].duration, 100_000, 10_000
  end
end
