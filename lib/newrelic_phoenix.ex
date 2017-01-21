defmodule NewRelicPhoenix do
  alias NewRelicPhoenix.{
    Transaction,
    TransactionRegistry,
  }

  @doc """

  """
  def record_segment(name, time) do
    TransactionRegistry.current
    |> Transaction.record_segment(name, time)
    |> TransactionRegistry.update
  end

  def start_transaction(name) do
    Transaction.start(name)
    |> TransactionRegistry.update
  end

  def finish_transaction do
    TransactionRegistry.delete
    |> Transaction.finish
    # TODO: send to statman/or aggregator
  end

  def start_segment(name) do
    TransactionRegistry.current
    |> Transaction.start_segment(name)
    |> TransactionRegistry.update
  end

  def finish_segment(name) do
    TransactionRegistry.current
    |> Transaction.finish_segment(name)
    |> TransactionRegistry.update
  end

  defmacro measure_segment(name, do: block) do
    quote do
      NewRelicPhoenix.start_segment(unquote(name))
      results = unquote(block)
      NewRelicPhoenix.finish_segment(unquote(name))
      results
    end
  end
end
