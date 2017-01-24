defmodule NewRelicPhoenix.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      worker(:statman_server, [push_frequency(), [], gc_frequency()]),
      worker(:statman_aggregator, []),
    ]

    opts = [strategy: :one_for_one, name: NewRelicPhoenix.Supervisor]
    result = Supervisor.start_link(children, opts)

    :ok = :statman_server.add_subscriber(:statman_aggregator)

    if app_name() && license_key() do
      Application.put_env(:newrelic, :application_name, to_char_list(app_name()))
      Application.put_env(:newrelic, :license_key, to_char_list(license_key()))

      {:ok, _} = :newrelic_poller.start_link(&:newrelic_statman.poll/0)
    end

    result
  end

  def push_frequency,
    do: Application.get_env(:newrelic_phoenix, :push_frequency, 1_000)

  def gc_frequency,
    do: Application.get_env(:newrelic_phoenix, :gc_frequency, 100_000)

  def app_name,
    do: get_env(:newrelic_phoenix, :application_name)

  def license_key,
    do: get_env(:newrelic_phoenix, :license_key)

  defp get_env(app, key, default \\ nil) do
    case Application.get_env(app, key, default) do
      {:system, system} -> System.get_env(system)
      other             -> other
    end
  end
end
