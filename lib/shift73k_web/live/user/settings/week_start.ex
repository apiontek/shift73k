defmodule Shift73kWeb.UserLive.Settings.WeekStart do
  use Shift73kWeb, :live_component
  import Shift73k, only: [weekdays: 0]

  alias Shift73k.Accounts

  @impl true
  def update(%{current_user: user} = assigns, socket) do
    socket
    |> assign(id: assigns.id)
    |> assign(current_user: user)
    |> assign(form_week_start_at: user.week_start_at)
    |> live_okreply()
  end

  def week_start_options do
    week_start = Date.beginning_of_week(Date.utc_today(), hd(weekdays()))

    week_start
    |> Date.range(Date.add(week_start, 6))
    |> Enum.map(&Calendar.strftime(&1, "%A"))
    |> Enum.zip(weekdays())
  end

  @impl true
  def handle_event("changed", %{"calendar_view" => %{"week_start_at" => day}}, socket) do
    {:noreply, assign(socket, form_week_start_at: String.to_existing_atom(day))}
  end

  @impl true
  def handle_event("save", %{"calendar_view" => %{"week_start_at" => day}}, socket) do
    Accounts.set_user_week_start_at(socket.assigns.current_user.id, day)
    flash_msg = {:info, "Calendar view settings updated."}
    send(self(), {:clear_flash_message, :error})
    send(self(), {:put_flash_message, flash_msg})
    send(self(), {:reload_current_user, true})
    {:noreply, socket}
  end
end
