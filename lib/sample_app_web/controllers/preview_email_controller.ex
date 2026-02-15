defmodule SampleAppWeb.PreviewEmailController do
  use SampleAppWeb, :controller

  plug :put_layout, false

  def show(conn, _params) do
    user = %SampleApp.Accounts.User{name: "Binh Tran", email: "binh@example.com"}
    activation_token = SampleApp.Token.gen_activation_token(user)
    email = SampleApp.Email.account_activation_email(user, activation_token)

    {to_name, to_email} = List.first(email.to)
    {from_name, from_email} = email.from

    render(conn, :show,
      email: email,
      to: "#{to_name} <#{to_email}>",
      from: "#{from_name} <#{from_email}>"
    )
  end
end
