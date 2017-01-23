defmodule NewRelicPhoenix.Endpoint do
  alias Phoenix.Controller
  import NewRelicPhoenix

  def phoenix_controller_call(:start, _compile_meta_data, %{conn: conn}) do
    controller = Controller.controller_module(conn)
    action = Controller.action_name(conn)
    name = "/#{controller}##{action}"
    start_transaction(name)
  end

  def phoenix_controller_call(:stop, _time_diff, _transaction) do
    finish_transaction()
  end

  def phoenix_controller_render(:start, _compile_time, runtime) do
    start_segment({:render, runtime[:template] || "template"})
    runtime
  end

  def phoenix_controller_render(:stop, _time_diff, runtime) do
    finish_segment({:render, runtime[:template] || "template"})
  end
end
