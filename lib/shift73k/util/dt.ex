defmodule Shift73k.Util.Dt do
  @app_vars Application.get_env(:shift73k, :app_global_vars, time_zone: "America/New_York")
  @time_zone @app_vars[:time_zone]

  def ndt_to_local(%NaiveDateTime{} = ndt), do: Timex.to_datetime(ndt, @time_zone)

  def format_dt_local(dt_local, fstr), do: Timex.format!(dt_local, fstr)

  def format_ndt(%NaiveDateTime{} = ndt, fstr), do: ndt |> ndt_to_local() |> format_dt_local(fstr)
end
