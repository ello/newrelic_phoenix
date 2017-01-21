defmodule NewRelicPhoenix.Transaction do
  defstruct [name: nil, segments: %{}, started_at: nil, duration: nil, pid: nil]

  defmodule Segment do
    defstruct [started_at: nil, duration: nil]
  end

  def start(name) do
    %__MODULE__{
      name: name,
      pid: self(),
      started_at: :os.timestamp()
    }
  end

  def finish(transaction) do
    duration = :timer.now_diff(:os.timestamp(), transaction.started_at)
    Map.put(transaction, :duration, duration)
  end

  def start_segment(transaction, name) do
    segment = %Segment{started_at: :os.timestamp()}
    Map.update!(transaction, :segments, &Map.merge(&1, %{name => segment}))
  end

  def finish_segment(transaction, name) do
    update_in transaction.segments[name], fn(segment) ->
      duration = :timer.now_diff(:os.timestamp(), segment.started_at)
      Map.put(segment, :duration, duration)
    end
  end

  def record_segment(transaction, name, duration) do
    segment = %Segment{duration: duration}
    Map.update!(transaction, :segments, &Map.merge(&1, %{name => segment}))
  end
end
