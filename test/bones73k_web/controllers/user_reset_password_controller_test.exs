defmodule Bones73kWeb.UserResetPasswordControllerTest do
  use Bones73kWeb.ConnCase, async: true

  alias Bones73k.Accounts
  alias Bones73k.Repo
  import Bones73k.AccountsFixtures

  setup do
    %{user: user_fixture()}
  end

  describe "GET /users/reset_password" do
    test "renders the reset password page", %{conn: conn} do
      conn = get(conn, Routes.user_reset_password_path(conn, :new))
      response = html_response(conn, 200)
      assert response =~ "Forgot your password?\n  </h2>"
    end

    test "redirects if already logged in", %{conn: conn} do
      to = Routes.user_reset_password_path(conn, :new)
      conn = conn |> log_in_user(user_fixture()) |> get(to)
      assert redirected_to(conn) == "/"
    end
  end

  describe "POST /users/reset_password" do
    @tag :capture_log
    test "sends a new reset password token", %{conn: conn, user: user} do
      conn =
        post(conn, Routes.user_reset_password_path(conn, :create), %{
          "user" => %{"email" => user.email}
        })

      assert redirected_to(conn) == "/"
      assert get_flash(conn, :info) =~ "If your email is in our system"
      assert Repo.get_by!(Accounts.UserToken, user_id: user.id).context == "reset_password"
    end

    test "does not send reset password token if email is invalid", %{conn: conn} do
      conn =
        post(conn, Routes.user_reset_password_path(conn, :create), %{
          "user" => %{"email" => "unknown@example.com"}
        })

      assert redirected_to(conn) == "/"
      assert get_flash(conn, :info) =~ "If your email is in our system"
      assert Repo.all(Accounts.UserToken) == []
    end
  end

  describe "GET /users/reset_password/:token" do
    setup %{user: user} do
      token =
        extract_user_token(fn url ->
          Accounts.deliver_user_reset_password_instructions(user, url)
        end)

      %{token: token}
    end

    test "renders reset password with user_id in session", %{conn: conn, token: token, user: user} do
      conn = get(conn, Routes.user_reset_password_path(conn, :edit, token))
      assert get_session(conn, "user_id") == user.id
      assert html_response(conn, 200) =~ "Reset password\n  </h2>"
    end

    test "does not render reset password with invalid token", %{conn: conn} do
      conn = get(conn, Routes.user_reset_password_path(conn, :edit, "oops"))
      assert redirected_to(conn) == "/"
      assert get_flash(conn, :error) =~ "Reset password link is invalid or it has expired"
    end
  end

  describe "PUT /users/reset_password/:token" do
    setup %{user: user} do
      token =
        extract_user_token(fn url ->
          Accounts.deliver_user_reset_password_instructions(user, url)
        end)

      %{token: token}
    end
  end
end
