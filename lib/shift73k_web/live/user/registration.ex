defmodule Shift73kWeb.UserLive.Registration do
  use Shift73kWeb, :live_view
  alias Shift73k.Repo
  alias Shift73k.Accounts
  alias Shift73k.Accounts.User

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
        success: "Welcome! Your new account has been created, and you've been logged in."
      ]
    }
  end

  @impl true
  def handle_event("validate", %{"user" => user_params}, socket) do
    cs = Accounts.change_user_registration(%User{}, user_params)
    {:noreply, assign(socket, changeset: %{cs | action: :validate})}
  end

  @impl true
  def handle_event("save", %{"user" => user_params}, socket) do
    is_first_user = !Repo.exists?(User)
    user_params
    |> Accounts.register_user()
    |> case do
      {:ok, user} ->
        # If this is the first user, we just confirm them
        if is_first_user do
          user |> User.confirm_changeset() |> Repo.update()
        else
          # Otherwise, all new users require email confirmation so we wend instructions
          {:ok, _, %Swoosh.Email{} = _captured_email} =
            Accounts.deliver_user_confirmation_instructions(
              user,
              &Routes.user_confirmation_url(socket, :confirm, &1)
            )
        end

        login_params =
          if is_first_user do
            socket.assigns.login_params
          else
            put_in(socket.assigns.login_params, [:messages, :info], "Some features may be unavailable until you confirm your email address. Check your inbox for instructions.")
          end
          |> put_in([:user_id], user.id)

        socket
        |> assign(login_params: login_params)
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
