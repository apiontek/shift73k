defmodule Bones73kWeb.UserLive.Registration do
  use Bones73kWeb, :live_view

  alias Bones73k.Accounts
  alias Bones73k.Accounts.User

  @impl true
  def mount(_params, session, socket) do
    socket
    |> assign_defaults(session)
    |> assign(page_title: "Register")
    |> assign(changeset: Accounts.change_user_registration(%User{}))
    |> assign(login_params: init_login_params(session))
    |> assign(trigger_submit: false)
    |> live_okreply()
  end

  defp init_login_params(session) do
    %{
      user_id: nil,
      user_return_to: Map.get(session, "user_return_to", "/"),
      messages: [
        success: "Welcome! Your new account has been created, and you've been logged in.",
        info:
          "Some features may be unavailable until you confirm your email address. Check your inbox for instructions."
      ]
    }
  end

  @impl true
  def handle_event("validate", %{"user" => user_params}, socket) do
    cs = Accounts.change_user_registration(%User{}, user_params)
    {:noreply, assign(socket, changeset: %{cs | action: :update})}
  end

  @impl true
  def handle_event("save", %{"user" => user_params}, socket) do
    user_params
    |> Map.put("role", Accounts.registration_role())
    |> Accounts.register_user()
    |> case do
      {:ok, user} ->
        %Bamboo.Email{} =
          Accounts.deliver_user_confirmation_instructions(
            user,
            &Routes.user_confirmation_url(socket, :confirm, &1)
          )

        socket
        |> assign(login_params: %{socket.assigns.login_params | user_id: user.id})
        |> assign(trigger_submit: true)
        |> live_noreply()

      {:error, cs} ->
        socket
        |> put_flash(:error, "Ope &mdash; registration failed for some reason.")
        |> assign(:changeset, cs)
        |> live_noreply()
    end
  end
end
