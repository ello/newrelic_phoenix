defmodule NewRelicPhoenix.Transaction do
  defstruct [
    name: nil,
    segments: %{},
    finished_segments: [],
    started_at: nil,
    duration: nil,
    pid: nil
  ]

  defmodule Segment do
    defstruct [name: nil, started_at: nil, duration: nil]
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
    segment = %Segment{started_at: :os.timestamp(), name: name}
    Map.update!(transaction, :segments, &Map.merge(&1, %{name => segment}))
  end

  def finish_segment(transaction, name) do
    {segment, transaction} = pop_in(transaction.segments[name])
    duration = :timer.now_diff(:os.timestamp(), segment.started_at)
    segment = Map.put(segment, :duration, duration)
    Map.update!(transaction, :finished_segments, &([segment | &1]))
  end

  def record_segment(transaction, name, duration) do
    segment = %Segment{duration: duration, name: name}
    Map.update!(transaction, :finished_segments, &([segment | &1]))
  end
end
