defmodule Shift73kWeb.UserManagement.FormComponent do
  use Shift73kWeb, :live_component

  alias Shift73k.Accounts
  alias Shift73k.Accounts.User
  alias Shift73kWeb.Roles

  @impl true
  def update(assigns, socket) do
    socket
    |> assign(assigns)
    |> init_changeset(assigns)
    |> live_okreply()
  end

  defp init_changeset(socket, %{action: :new, user: user}) do
    params = %{role: Accounts.registration_role()}
    assign(socket, changeset: Accounts.change_user_registration(user, params))
  end

  defp init_changeset(socket, %{action: :edit, user: user}) do
    assign(socket, changeset: Accounts.change_user_update(user))
  end

  defp validate_changes(%{action: :new, user: user}, user_params) do
    Accounts.change_user_registration(user, user_params)
  end

  defp validate_changes(%{action: :edit, user: user}, user_params) do
    Accounts.change_user_update(user, user_params)
  end

  defp save_user(%{assigns: %{action: :new}} = socket, user_params) do
    case Accounts.register_user(user_params) do
      {:ok, user} ->
        {:ok, %Bamboo.Email{}} =
          Accounts.deliver_user_confirmation_instructions(
            user,
            &Routes.user_confirmation_url(socket, :confirm, &1)
          )

        flash = {:info, "User created successfully: #{user.email}"}
        send(self(), {:put_flash_message, flash})

        socket
        |> push_event("modal-please-hide", %{})
        |> live_noreply()

      {:error, cs} ->
        socket
        |> put_flash(:error, "Some error creating this user...")
        |> assign(changeset: cs)
        |> live_noreply()
    end
  end

  defp save_user(%{assigns: %{action: :edit, user: user}} = socket, user_params) do
    case Accounts.update_user(user, user_params) do
      {:ok, user} ->
        flash = {:info, "User updated successfully: #{user.email}"}
        send(self(), {:put_flash_message, flash})

        socket
        |> push_event("modal-please-hide", %{})
        |> live_noreply()

      {:error, cs} ->
        {:noreply, assign(socket, :changeset, cs)}
    end
  end

  @impl true
  def handle_event("validate", %{"user" => user_params}, socket) do
    cs = validate_changes(socket.assigns, user_params)
    {:noreply, assign(socket, :changeset, %{cs | action: :validate})}
  end

  @impl true
  def handle_event("save", %{"user" => user_params}, socket) do
    save_user(socket, user_params)
  end

  def role_description(role) when is_atom(role) do
    Keyword.get(User.roles(), role)
  end

  def role_description(role) when is_binary(role) do
    Keyword.get(User.roles(), String.to_existing_atom(role))
  end
end
