defmodule SampleAppWeb.AccountActivationController do
  use SampleAppWeb, :controller
  alias SampleApp.Accounts
  alias SampleApp.Accounts.User
  alias SampleAppWeb.AuthPlug

  def edit(conn, %{"id" => token}) do
    with {:ok, user_id} <- SampleApp.Token.verify_activation_token(token),
         %User{activated: false} = user <- Accounts.get_user(user_id),
         {:ok, %User{activated: true} = user} <- Accounts.activate_user(user) do
      conn
      |> AuthPlug.login(user)
      |> put_flash(:info, "Welcome to the Sample App!")
      |> redirect(to: ~p"/users/#{user_id}")
    else
      _ ->
        conn
        |> put_flash(:error, "Invalid activation link")
        |> redirect(to: ~p"/")
    end
  end

  def edit(conn, _params) do
    conn
    |> put_flash(:error, "Invalid activation link")
    |> redirect(to: ~p"/")
  end
end
