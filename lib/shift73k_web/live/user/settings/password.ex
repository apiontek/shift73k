defmodule Shift73kWeb.UserLive.Settings.Password do
  use Shift73kWeb, :live_component

  alias Shift73k.Accounts
  alias Shift73k.Accounts.User

  @impl true
  def update(%{current_user: user} = assigns, socket) do
    socket
    |> assign(id: assigns.id)
    |> assign(current_user: user)
    |> assign(changeset: get_changeset(user))
    |> assign(login_params: init_login_params(socket))
    |> assign(trigger_submit: false)
    |> live_okreply()
  end

  defp get_changeset(user, user_params \\ %{}) do
    Accounts.change_user_password(user, user_params)
  end

  defp init_login_params(socket) do
    %{
      user_id: nil,
      user_return_to: Routes.user_settings_path(socket, :edit),
      messages: [info: "Password updated successfully."]
    }
  end

  @impl true
  def handle_event("validate", %{"user" => user_params}, socket) do
    cs = get_changeset(socket.assigns.current_user, user_params)
    {:noreply, assign(socket, changeset: %{cs | action: :validate})}
  end

  @impl true
  def handle_event("save", %{"user" => user_params}, socket) do
    case Accounts.update_user_password(socket.assigns.current_user, user_params) do
      {:ok, user} ->
        socket
        |> assign(login_params: %{socket.assigns.login_params | user_id: user.id})
        |> assign(trigger_submit: true)
        |> live_noreply()

      {:error, cs} ->
        cu = socket.assigns.current_user
        cpw = user_params["current_password"]
        valid_password? = User.valid_password?(cu, cpw)
        msg = (valid_password? && "Could not change password.") || "Invalid current password."
        send(self(), {:put_flash_message, {:error, msg}})

        socket
        |> assign(changeset: cs)
        |> live_noreply()
    end
  end
end
