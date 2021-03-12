defmodule Shift73kWeb.UserLive.Settings do
  use Shift73kWeb, :live_view

  alias Shift73k.Accounts
  alias Shift73k.Accounts.User

  @impl true
  def mount(_params, session, socket) do
    socket
    |> assign_defaults(session)
    |> alert_email_verified?()
    |> live_okreply()
  end

  defp alert_email_verified?(socket) do
    case socket.assigns.current_user do
      %{confirmed_at: nil} ->
        put_flash(socket, :warning, [
          "Your email hasn't been confirmed, some areas may be restricted. Shall we ",
          link("resend the verification email?",
            to: Routes.user_confirmation_path(socket, :new),
            class: "alert-link"
          )
        ])

      _ ->
        socket
    end
  end

  @impl true
  def handle_info({:put_flash_message, {flash_type, msg}}, socket) do
    socket |> put_flash(flash_type, msg) |> live_noreply()
  end

  @impl true
  def handle_info({:clear_flash_message, flash_type}, socket) do
    socket |> clear_flash(flash_type) |> live_noreply()
  end

  @impl true
  def handle_info({:reload_current_user, _}, socket) do
    socket
    |> assign(:current_user, Accounts.get_user!(socket.assigns.current_user.id))
    |> live_noreply()
  end
end
