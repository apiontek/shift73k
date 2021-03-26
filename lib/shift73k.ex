defmodule Shift73k do
  @moduledoc """
  Shift73k keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  @app_vars Application.get_env(:shift73k, :app_global_vars, time_zone: "America/New_York")
  @app_time_zone @app_vars[:time_zone]

  @weekdays [:monday, :tuesday, :wednesday, :thursday, :friday, :saturday, :sunday]

  def app_time_zone, do: @app_time_zone

  def weekdays, do: @weekdays
end
