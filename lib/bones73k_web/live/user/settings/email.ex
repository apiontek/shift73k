defmodule Bones73kWeb.UserLive.Settings.Email do
  use Bones73kWeb, :live_component

  alias Bones73k.Accounts
  alias Bones73k.Accounts.User

  @impl true
  def update(%{current_user: user} = assigns, socket) do
    socket
    |> assign(id: assigns.id)
    |> assign(current_user: user)
    |> assign(changeset: get_changeset(user))
    |> live_okreply()
  end

  defp get_changeset(user, user_params \\ %{}) do
    Accounts.change_user_email(user, user_params)
  end

  @impl true
  def handle_event("validate", %{"user" => user_params}, socket) do
    cs = get_changeset(socket.assigns.current_user, user_params)
    {:noreply, assign(socket, changeset: %{cs | action: :update})}
  end

  # user_settings_path  GET     /users/settings/confirm_email/:token   Bones73kWeb.UserSettingsController :confirm_email

  @impl true
  def handle_event("save", %{"user" => user_params}, socket) do
    case Accounts.apply_user_email(socket.assigns.current_user, user_params) do
      {:ok, applied_user} ->
        Accounts.deliver_update_email_instructions(
          applied_user,
          socket.assigns.current_user.email,
          &Routes.user_settings_url(socket, :confirm_email, &1)
        )

        send(self(), {:clear_flash_message, :error})

        send(
          self(),
          {:put_flash_message,
           {:info, "A link to confirm your e-mail change has been sent to the new address."}}
        )

        socket
        |> assign(changeset: get_changeset(socket.assigns.current_user))
        |> live_noreply()

      {:error, cs} ->
        cu = socket.assigns.current_user
        cpw = user_params["current_password"]
        valid_password? = User.valid_password?(cu, cpw)
        msg = (valid_password? && "Could not reset email.") || "Invalid current password."
        send(self(), {:put_flash_message, {:error, msg}})

        socket
        |> assign(changeset: cs)
        |> live_noreply()
    end
  end
end
