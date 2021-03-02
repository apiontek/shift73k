defmodule Bones73kWeb.UserLive.RegistrationTest do
  use Bones73kWeb.ConnCase

  import Phoenix.LiveViewTest
  import Bones73k.AccountsFixtures

  alias Bones73k.Accounts
  alias Bones73k.Accounts.User

  describe "Registration" do
    setup %{conn: conn} do
      user_return_to = "/path-requires-auth"
      conn = init_test_session(conn, %{"user_return_to" => user_return_to})
      %{conn: conn, user_return_to: user_return_to}
    end

    test "displays registration form", %{conn: conn} do
      {:ok, _view, html} = live_isolated(conn, Bones73kWeb.UserLive.Registration)

      assert html =~ "Register\n  </h3>"
      assert html =~ "Email</label>"
    end

    test "render errors for invalid data", %{conn: conn} do
      {:ok, view, _html} = live_isolated(conn, Bones73kWeb.UserLive.Registration)

      html =
        view
        |> form("#reg_form", %{"user" => %{"email" => "abc", "password" => "abc"}})
        |> render_change()

      assert html =~ "Register\n  </h3>"
      assert html =~ "must be a valid email address"
      assert html =~ "should be at least #{User.min_password()} character(s)"
      assert html =~ "type=\"submit\" disabled=\"disabled\""
    end

    @tag :capture_log
    test "creates account, sets login token & phx-trigger-action", %{
      conn: conn,
      user_return_to: user_return_to
    } do
      {:ok, view, html} = live_isolated(conn, Bones73kWeb.UserLive.Registration)

      # Login trigger form not triggered yet
      refute html =~ "phx-trigger-action=\"phx-trigger-action\""

      # Render registering a new user
      email = unique_user_email()
      form_data = %{"user" => %{"email" => email, "password" => valid_user_password()}}
      html = form(view, "#reg_form", form_data) |> render_submit()

      # Confirm user was registered
      %User{email: new_user_email, id: new_user_id} = Accounts.get_user_by_email(email)
      assert new_user_email == email

      # Login trigger form activated?
      assert html =~ "phx-trigger-action=\"phx-trigger-action\""

      # Collect the rendered login params token
      [params_token] = Floki.attribute(html, "input#user_params_token", "value")
      {:ok, params} = Phoenix.Token.decrypt(Bones73kWeb.Endpoint, "login_params", params_token)
      %{user_id: param_user_id, user_return_to: param_return_path} = params

      # Token in login trigger form has correct user ID?
      assert new_user_id == param_user_id
      # ... and correct user_return_to path?
      assert user_return_to == param_return_path
    end
  end
end
