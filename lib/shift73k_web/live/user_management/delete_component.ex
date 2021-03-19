defmodule Shift73kWeb.UserManagement.DeleteComponent do
  use Shift73kWeb, :live_component

  alias Shift73k.Accounts

  @impl true
  def update(assigns, socket) do
    socket |> assign(assigns) |> live_okreply()
  end

  @impl true
  def handle_event("confirm", %{"id" => id, "email" => email}, socket) do
    id
    |> Accounts.get_user()
    |> Accounts.delete_user()
    |> case do
      {:ok, _} ->
        flash = {:info, "User deleted successfully: \"#{email}\""}
        send(self(), {:put_flash_message, flash})

        socket
        |> push_event("modal-please-hide", %{})
        |> live_noreply()

      {:error, _} ->
        flash =
          {:error,
           "Some error trying to delete user \"#{email}\". Possibly already deleted? Reloading list..."}

        send(self(), {:put_flash_message, flash})

        socket
        |> push_event("modal-please-hide", %{})
        |> live_noreply()
    end
  end
end
