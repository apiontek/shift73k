defmodule Bones73k.Mailer.UserEmail do
  import Bamboo.Email

  @mailer_vars Application.get_env(:bones73k, :app_global_vars,
                 mailer_reply_to: "admin@example.com",
                 mailer_from: {"Bones73k", "bones73k@example.com"}
               )

  def compose(user, subject, body_text) do
    new_email()
    |> from(@mailer_vars[:mailer_from])
    |> to(user.email)
    |> put_header("Reply-To", @mailer_vars[:mailer_reply_to])
    |> subject(subject)
    |> text_body(body_text)
  end
end
