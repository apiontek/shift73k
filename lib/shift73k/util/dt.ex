defmodule Shift73k.Util.Dt do
  @app_vars Application.get_env(:shift73k, :app_global_vars, time_zone: "America/New_York")
  @app_time_zone @app_vars[:time_zone]

  def app_time_zone, do: @app_time_zone
end
