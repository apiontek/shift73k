defmodule Shift73k.Mailer.UserEmail do
  import Swoosh.Email

  @mailer_vars Application.compile_env(:shift73k, :app_global_vars,
                 mailer_reply_to: "admin@example.com",
                 mailer_from: {"Shift73k", "shift73k@example.com"}
               )

  def compose(user_email, subject, body_text) do
    new()
    |> from(@mailer_vars[:mailer_from])
    |> to(user_email)
    |> header("Reply-To", @mailer_vars[:mailer_reply_to])
    |> subject(subject)
    |> text_body(body_text)
  end
end
