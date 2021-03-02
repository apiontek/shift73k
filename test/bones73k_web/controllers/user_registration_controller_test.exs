defmodule Bones73kWeb.UserRegistrationControllerTest do
  use Bones73kWeb.ConnCase, async: true

  import Bones73k.AccountsFixtures

  describe "GET /users/register" do
    test "renders registration page", %{conn: conn} do
      conn = get(conn, Routes.user_registration_path(conn, :new))
      response = html_response(conn, 200)
      assert response =~ "Register\n  </h3>"
      assert response =~ "Log in\n</a>"
      assert response =~ "Register\n</a>"
    end

    test "redirects if already logged in", %{conn: conn} do
      to = Routes.user_registration_path(conn, :new)
      conn = conn |> log_in_user(user_fixture()) |> get(to)
      assert redirected_to(conn) == "/"
    end
  end
end
