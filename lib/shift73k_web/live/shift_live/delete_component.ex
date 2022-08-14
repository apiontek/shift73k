defmodule Shift73kWeb.ShiftLive.DeleteComponent do
  use Shift73kWeb, :live_component

  alias Shift73k.Shifts

  @impl true
  def update(assigns, socket) do
    socket
    |> assign(assigns)
    |> live_okreply()
  end

  @impl true
  def handle_event("confirm", %{"id" => id, "subject" => subject, "datetime" => datetime}, socket) do
    shift = Shifts.get_shift(id)

    if (shift) do
      shift
      |> Shifts.delete_shift()
      |> case do
        {:ok, _} ->
          flash = {:info, "Shift deleted successfully: \"#{subject}\""}
          send(self(), {:put_flash_message, flash})

          socket
          |> push_event("modal-please-hide", %{})
          |> live_noreply()

        {:error, _} ->
          handle_error(socket, subject, datetime)
      end
    end
  end

  defp handle_error(socket, subject, datetime) do
    flash =
      {:error,
      "Some error trying to delete shift \"#{subject} (#{datetime})\". Possibly already deleted? Reloading list..."}

    send(self(), {:put_flash_message, flash})

    socket
    |> push_event("modal-please-hide", %{})
    |> live_noreply()
  end
end
