defmodule Bones73kWeb.UserSessionController do
  use Bones73kWeb, :controller

  alias Bones73k.Accounts
  alias Bones73k.Accounts.User
  alias Bones73kWeb.UserAuth

  def new(conn, _params) do
    # IO.inspect(conn.private, label: "session_new conn.private :")
    render(conn, "new.html", error_message: nil)
  end

  def create(conn, %{"user" => %{"email" => email, "password" => password} = user_params}) do
    if user = Accounts.get_user_by_email_and_password(email, password) do
      UserAuth.log_in_user(conn, user, user_params)
    else
      render(conn, "new.html", error_message: "Invalid email or password")
    end
  end

  def create(conn, %{"user" => %{"params_token" => token} = user_params}) do
    with {:ok, params} <- Phoenix.Token.decrypt(Bones73kWeb.Endpoint, "login_params", token),
         %User{} = user <- Accounts.get_user(params.user_id) do
      conn
      |> collect_messages(params.messages)
      |> put_session(:user_return_to, params.user_return_to)
      |> UserAuth.log_in_user(user, Map.put_new(user_params, "remember_me", "false"))
    else
      _ -> render(conn, "new.html", error_message: "Invalid email or password")
    end
  end

  defp collect_messages(conn, messages) do
    Enum.reduce(messages, conn, fn {type, msg}, acc -> put_flash(acc, type, msg) end)
  end

  def delete(conn, _params) do
    conn
    |> put_flash(:info, "Logged out successfully.")
    |> UserAuth.log_out_user()
  end

  def force_logout(conn, _params) do
    conn
    |> put_flash(
      :info,
      "You were logged out. Please login again to continue using our application."
    )
    |> UserAuth.log_out_user()
  end
end
