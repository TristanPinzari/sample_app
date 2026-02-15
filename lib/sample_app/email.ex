defmodule SampleApp.Email do
  use Swoosh.Mailer, otp_app: :sample_app
  import Swoosh.Email
  alias SampleAppWeb.EmailHTML

  def account_activation_email(user, token) do
    assigns = %{user: user, activation_token: token}

    html_body_content =
      EmailHTML.account_activation_email(assigns)
      |> Phoenix.HTML.Safe.to_iodata()
      |> IO.iodata_to_binary()

    text_content =
      EmailHTML.account_activation_email_text(assigns)
      |> Phoenix.HTML.Safe.to_iodata()
      |> IO.iodata_to_binary()

    new()
    |> to({user.name, user.email})
    |> from({"Sample App", "noreply@example.com"})
    |> subject("Sample App - Account Activation")
    |> html_body(html_body_content)
    |> text_body(text_content)
  end
end
