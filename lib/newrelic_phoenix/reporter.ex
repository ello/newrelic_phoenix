defmodule NewRelicPhoenix.Reporter do
  alias NewRelicPhoenix.{
    Transaction
  }

  def aggregate(transaction) do
    report_segments(transaction)
    report_total(transaction)
    transaction
  end

  defp report_segments(%Transaction{name: name, finished_segments: segments}) do
    Enum.each segments, fn(%{name: segment_name, duration: duration}) ->
      statman().record_value({name, segment_name}, duration)
    end
  end

  defp report_total(%Transaction{name: name, duration: duration}) do
    statman().record_value({name, :total}, duration)
  end

  defp statman do
    Application.get_env(:newrelic_phoenix, :statman, :statman_histogram)
  end
end
