defmodule NewRelicPhoenix.Ecto do
  import NewRelicPhoenix, only: [record_segment: 2]

  @moduledoc """
  Enable logging of ecto queries to New Relic.

  Assumes you have already started a transaction (usually via
  NewRelicPhoenix.Endpoint).

  Just add to your config:

      config :my_app, MyApp.Repo,
        loggers: [{Ecto.LogEntry, :log, []}, NewRelicPhoenix.Ecto]

  """

  @doc """
  Send queue, query, and decode time to New Relic.

  Segment names will be command_on_table-(queue|query|decode) when we can tell.
  """
  def log(entry) do
    record_segment({:db, segment(entry, "queue")},  to_ms(entry.queue_time))
    record_segment({:db, segment(entry, "query")},  to_ms(entry.query_time))
    record_segment({:db, segment(entry, "decode")}, to_ms(entry.decode_time))
  end

  defp segment(%{source: source, result: {:ok, %{command: command}}}, part) when is_binary(source),
    do: "Ecto.#{part}.#{command}-#{source}"
  defp segment(%{source: _, result: {:ok, %{command: command}}}, part),
    do: "Ecto.#{part}.#{command}"
  defp segment(_, part),
    do: "Ecto.#{part}.unknown"

  defp to_ms(native),
    do: System.convert_time_unit(native, :native, :microseconds)
end
