defmodule Bones73kWeb.UserSessionControllerTest do
  use Bones73kWeb.ConnCase, async: true

  import Bones73k.AccountsFixtures

  setup do
    %{user: user_fixture()}
  end

  describe "GET /users/log_in" do
    test "renders log in page", %{conn: conn} do
      conn = get(conn, Routes.user_session_path(conn, :new))
      response = html_response(conn, 200)
      assert response =~ "\n    Log in\n  </h2>"
      assert response =~ "Register\n</a>"
      assert response =~ "Log in\n</a>"
    end

    test "redirects if already logged in", %{conn: conn, user: user} do
      conn = conn |> log_in_user(user) |> get(Routes.user_session_path(conn, :new))
      assert redirected_to(conn) == "/"
    end
  end

  describe "POST /users/log_in with credential params" do
    test "credential params logs the user in", %{conn: conn, user: user} do
      conn =
        post(conn, Routes.user_session_path(conn, :create), %{
          "user" => %{"email" => user.email, "password" => valid_user_password()}
        })

      assert get_session(conn, :user_token)
      assert redirected_to(conn) =~ "/"

      # Now do a logged in request and assert on the menu
      conn = get(conn, "/")
      response = html_response(conn, 200)
      assert response =~ user.email
      assert response =~ "Settings\n</a>"
      assert response =~ "Log out\n</a>"
    end

    test "logs the user in with remember me", %{conn: conn, user: user} do
      conn =
        post(conn, Routes.user_session_path(conn, :create), %{
          "user" => %{
            "email" => user.email,
            "password" => valid_user_password(),
            "remember_me" => "true"
          }
        })

      assert conn.resp_cookies["user_remember_me"]
      assert redirected_to(conn) =~ "/"
    end

    test "emits error message with invalid credentials", %{conn: conn, user: user} do
      conn =
        post(conn, Routes.user_session_path(conn, :create), %{
          "user" => %{"email" => user.email, "password" => "invalid_password"}
        })

      response = html_response(conn, 200)
      assert response =~ "\n    Log in\n  </h2>"
      assert response =~ "Invalid email or password"
    end
  end

  describe "POST /users/log_in with params token" do
    test "params token logs the user in", %{conn: conn, user: user} do
      params_token = login_params_token(user, "/users/settings")

      conn =
        post(conn, Routes.user_session_path(conn, :create), %{
          "user" => %{"params_token" => params_token}
        })

      assert get_session(conn, :user_token)
      assert redirected_to(conn) =~ "/"

      # Now do a logged in request and assert on the menu
      conn = get(conn, "/")
      response = html_response(conn, 200)
      assert response =~ user.email
      assert response =~ "Settings\n</a>"
      assert response =~ "Log out\n</a>"
    end

    test "logs the user in with remember me", %{conn: conn, user: user} do
      params_token = login_params_token(user, "/users/settings")

      conn =
        post(conn, Routes.user_session_path(conn, :create), %{
          "user" => %{
            "params_token" => params_token,
            "remember_me" => "true"
          }
        })

      assert conn.resp_cookies["user_remember_me"]
      assert redirected_to(conn) =~ "/"
    end

    test "emits error message with invalid params token", %{conn: conn} do
      conn =
        post(conn, Routes.user_session_path(conn, :create), %{
          "user" => %{"params_token" => "invalid params token"}
        })

      response = html_response(conn, 200)
      assert response =~ "\n    Log in\n  </h2>"
      assert response =~ "Invalid email or password"
    end
  end

  describe "DELETE /users/log_out" do
    test "logs the user out", %{conn: conn, user: user} do
      conn = conn |> log_in_user(user) |> delete(Routes.user_session_path(conn, :delete))
      assert redirected_to(conn) == "/"
      refute get_session(conn, :user_token)
      assert get_flash(conn, :info) =~ "Logged out successfully"
    end

    test "succeeds even if the user is not logged in", %{conn: conn} do
      conn = delete(conn, Routes.user_session_path(conn, :delete))
      assert redirected_to(conn) == "/"
      refute get_session(conn, :user_token)
      assert get_flash(conn, :info) =~ "Logged out successfully"
    end
  end
end
