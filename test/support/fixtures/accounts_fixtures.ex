defmodule Shift73k.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Shift73k.Accounts` context.
  """

  def unique_user_email, do: "user#{System.unique_integer()}@example.com"
  def valid_user_password, do: "ValidPass47"

  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(%{
        email: unique_user_email(),
        password: valid_user_password()
      })
      |> Shift73k.Accounts.register_user()

    user
  end

  def admin_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(%{
        role: :admin,
        email: unique_user_email(),
        password: valid_user_password()
      })
      |> Shift73k.Accounts.register_user()

    user
  end

  def extract_user_token(fun) do
    {:ok, _, %Swoosh.Email{} = captured_email} = fun.(&"[TOKEN]#{&1}[TOKEN]")
    [_, token | _] = String.split(captured_email.text_body, "[TOKEN]")
    token
  end

  def login_params_token(user, return_path) do
    Phoenix.Token.encrypt(Shift73kWeb.Endpoint, "login_params", %{
      user_id: user.id,
      user_return_to: return_path,
      messages: [
        success: "A message of success!",
        info: "Some information as well."
      ]
    })
  end
end
