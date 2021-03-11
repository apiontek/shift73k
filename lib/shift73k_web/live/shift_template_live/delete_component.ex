defmodule Shift73kWeb.ShiftTemplateLive.DeleteComponent do
  use Shift73kWeb, :live_component

  alias Shift73k.Shifts.Templates

  @impl true
  def update(assigns, socket) do
    socket
    |> assign(assigns)
    |> live_okreply()
  end

  @impl true
  def handle_event("cancel", _, socket) do
    {:noreply, push_event(socket, "modal-please-hide", %{})}
  end

  @impl true
  def handle_event("confirm", %{"id" => id, "subject" => subject}, socket) do
    id
    |> Templates.get_shift_template()
    |> Templates.delete_shift_template()
    |> case do
      {:ok, _} ->
        flash = {:info, "Shift template deleted successfully: \"#{subject}\""}
        send(self(), {:put_flash_message, flash})

        socket
        |> push_event("modal-please-hide", %{})
        |> live_noreply()

      {:error, _} ->
        flash =
          {:error,
           "Some error trying to delete shift template \"#{subject}\". Possibly already deleted? Reloading list..."}

        send(self(), {:put_flash_message, flash})

        socket
        |> push_event("modal-please-hide", %{})
        |> live_noreply()
    end
  end
end
