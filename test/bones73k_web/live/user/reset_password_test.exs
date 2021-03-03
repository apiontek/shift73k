defmodule Bones73kWeb.UserLive.ResetPasswordTest do
  use Bones73kWeb.ConnCase

  import Phoenix.LiveViewTest
  import Bones73k.AccountsFixtures

  alias Bones73k.Repo
  alias Bones73k.Accounts
  alias Bones73k.Accounts.{User, UserToken}

  setup %{conn: conn} do
    user = user_fixture()
    conn = init_test_session(conn, %{"user_id" => user.id})
    %{conn: conn, user: user}
  end

  test "displays registration form", %{conn: conn, user: user} do
    {:ok, _view, html} = live_isolated(conn, Bones73kWeb.UserLive.ResetPassword)

    assert html =~ "Reset password\n  </h2>"
    assert html =~ user.email
    assert html =~ "New password</label>"
  end

  test "render errors for invalid data", %{conn: conn} do
    {:ok, view, _html} = live_isolated(conn, Bones73kWeb.UserLive.ResetPassword)

    form_data = %{"user" => %{"password" => "abc", "password_confirmation" => "def"}}
    html = form(view, "#pw_reset_form", form_data) |> render_change()

    assert html =~ "Reset password\n  </h2>"
    assert html =~ "should be at least #{User.min_password()} character(s)"
    assert html =~ "does not match password"
    assert html =~ "type=\"submit\" disabled=\"disabled\""
  end

  @tag :capture_log
  test "saves new password once", %{conn: conn, user: user} do
    {:ok, view, _html} = live_isolated(conn, Bones73kWeb.UserLive.ResetPassword)

    # Render submitting a new password
    new_pw = "valid_new_pass_123"
    form_data = %{"user" => %{"password" => new_pw, "password_confirmation" => new_pw}}
    _html = form(view, "#pw_reset_form", form_data) |> render_submit()

    # Confirm redirected
    flash = assert_redirected(view, Routes.user_session_path(conn, :new))
    assert flash["info"] == "Password reset successfully."

    # Confirm password was updated
    assert Accounts.get_user_by_email_and_password(user.email, new_pw)

    # Tokens have been deleted
    assert [] == Repo.all(UserToken.user_and_contexts_query(user, :all))
  end
end
