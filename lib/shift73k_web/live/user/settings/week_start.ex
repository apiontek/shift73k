defmodule Shift73kWeb.UserLive.Settings.WeekStart do
  use Shift73kWeb, :live_component

  alias Shift73k.EctoEnums.WeekdayEnum
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
    WeekdayEnum.__enum_map__() |> Enum.map(fn {d, n} -> {Timex.day_name(n), d} end)
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
