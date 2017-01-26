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
    Enum.each(segments, &report_segment(name, &1))
  end

  defp report_segment(_, %{duration: nil}), do: nil
  defp report_segment(transaction, %{name: segment, duration: duration}) do
    statman().record_value({transaction, segment}, duration)
  end

  defp report_total(%Transaction{duration: nil}), do: nil
  defp report_total(%Transaction{name: name, duration: duration}) do
    statman().record_value({name, :total}, duration)
  end

  defp statman do
    Application.get_env(:newrelic_phoenix, :statman, :statman_histogram)
  end
end
