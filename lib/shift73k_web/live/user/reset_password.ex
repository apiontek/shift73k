defmodule Shift73kWeb.UserLive.ResetPassword do
  use Shift73kWeb, :live_view

  alias Shift73k.Accounts
  alias Shift73k.Accounts.User

  @impl true
  def mount(_params, session, socket) do
    user = Accounts.get_user!(session["user_id"])

    socket
    |> assign_defaults(session)
    |> assign(page_title: "Reset password")
    |> assign(changeset: Accounts.change_user_password(user))
    |> assign(user: user)
    |> live_okreply()
  end

  @impl true
  def handle_event("validate", %{"user" => user_params}, socket) do
    cs = Accounts.change_user_password(socket.assigns.user, user_params)
    {:noreply, socket |> assign(changeset: %{cs | action: :validate})}
  end

  def handle_event("save", %{"user" => user_params}, socket) do
    case Accounts.reset_user_password(socket.assigns.user, user_params) do
      {:ok, _} ->
        {:noreply,
         socket
         |> put_flash(:info, "Password reset successfully.")
         |> redirect(to: Routes.user_session_path(socket, :new))}

      {:error, changeset} ->
        {:noreply,
         socket
         |> put_flash(:error, "Please check the errors below.")
         |> assign(changeset: changeset)}
    end
  end
end
