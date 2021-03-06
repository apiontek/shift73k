defmodule Shift73k.Accounts.UserNotifier do
  alias Shift73k.Mailer
  alias Shift73k.Mailer.UserEmail

  @doc """
  Deliver instructions to confirm account.
  """
  def deliver_confirmation_instructions(user, url) do
    user
    |> UserEmail.compose("Confirm Your Account", """

    ==============================

    Hi #{user.email},

    You can confirm your account by visiting the URL below:

    #{url}

    If you didn't create an account with us, please ignore this.

    ==============================
    """)
    |> Mailer.deliver_later()
  end

  @doc """
  Deliver instructions to reset a user password.
  """
  def deliver_reset_password_instructions(user, url) do
    user
    |> UserEmail.compose("Reset Your Password", """

    ==============================

    Hi #{user.email},

    You can reset your password by visiting the URL below:

    #{url}

    If you didn't request this change, please ignore this.

    ==============================
    """)
    |> Mailer.deliver_later()
  end

  @doc """
  Deliver instructions to update a user email.
  """
  def deliver_update_email_instructions(user, url) do
    user
    |> UserEmail.compose("Change Your E-mail", """

    ==============================

    Hi #{user.email},

    You can change your email by visiting the URL below:

    #{url}

    If you didn't request this change, please ignore this.

    ==============================
    """)
    |> Mailer.deliver_later()
  end
end
