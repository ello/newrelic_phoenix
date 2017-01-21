defmodule NewRelicPhoenix.TransactionRegistry do
  @moduledoc false
  alias NewRelicPhoenix.Transaction

  @key :newrelic_phoenix

  @doc false
  def current,
    do: Process.get(@key) || %Transaction{}

  @doc false
  def update(transaction) do
    Process.put(@key, transaction)
    transaction
  end

  @doc false
  def delete,
    do: Process.delete(@key) || %Transaction{}

end
