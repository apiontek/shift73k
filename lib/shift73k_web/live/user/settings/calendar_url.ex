defmodule Shift73kWeb.UserLive.Settings.CalendarUrl do
  use Shift73kWeb, :live_component

  alias Shift73k.Accounts

  @impl true
  def update(%{current_user: user} = assigns, socket) do
    socket
    |> assign(id: assigns.id)
    |> assign(current_user: user)
    |> live_okreply()
  end

  @impl true
  def handle_event("save", _params, socket) do
    Accounts.change_user_calendar_slug(socket.assigns.current_user.id)
    flash_msg = {:info, "New calendar URL generated."}
    send(self(), {:clear_flash_message, :error})
    send(self(), {:put_flash_message, flash_msg})
    send(self(), {:reload_current_user, true})
    {:noreply, socket}
  end
end
