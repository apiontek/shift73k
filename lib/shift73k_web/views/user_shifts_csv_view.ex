defmodule Shift73kWeb.UserShiftsCsvView do
  use Shift73kWeb, :view

  alias Shift73k.Shifts

  def min_user_shift_date(user_id) do
    Shifts.get_min_user_shift_date(user_id) |> Date.to_string()
  end

  def max_user_shift_date(user_id) do
    Shifts.get_max_user_shift_date(user_id) |> Date.to_string()
  end
end
