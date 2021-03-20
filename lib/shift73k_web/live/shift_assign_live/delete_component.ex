defmodule Shift73kWeb.ShiftAssignLive.DeleteComponent do
  use Shift73kWeb, :live_component

  alias Shift73k.Shifts

  @impl true
  def update(assigns, socket) do
    socket
    |> assign(assigns)
    |> assign_dates()
    |> live_okreply()
  end

  defp assign_dates(%{assigns: %{delete_days_shifts: daylist}} = socket) do
    date_list = Enum.map(daylist, &Date.from_iso8601!/1)
    year_map = Enum.group_by(date_list, fn d -> d.year end)
    assign(socket, date_list: date_list, date_map: build_date_map(year_map))
  end

  def build_date_map(year_map) do
    year_map
    |> Map.keys()
    |> Enum.reduce(year_map, fn y, acc ->
      Map.put(acc, y, Enum.group_by(acc[y], fn d -> d.month end))
    end)
  end

  @impl true
  def handle_event("confirm-delete-days-shifts", _params, socket) do
    user = socket.assigns.current_user
    date_list = socket.assigns.date_list
    {n, _} = Shifts.delete_shifts_by_user_from_list_of_dates(user.id, date_list)
    s = (n > 1 && "s") || ""
    flash = {:info, "Successfully deleted #{n} assigned shift#{s}"}
    send(self(), {:put_flash_message, flash})
    send(self(), {:clear_selected_days, true})

    socket
    |> push_event("modal-please-hide", %{})
    |> live_noreply()
  end
end
