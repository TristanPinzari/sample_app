defmodule SampleAppWeb.SessionController do
  use SampleAppWeb, :controller
  alias SampleApp.Accounts
  alias SampleAppWeb.AuthPlug

  def new(conn, _params) do
    conn
    |> assign(:page_title, "Login")
    |> render(:login, changeset: Accounts.change_user(%Accounts.User{}))
  end

  def create(conn, %{"user" => user_params}) do
    case Accounts.authenticate_by_email_and_pass(user_params["email"], user_params["password"]) do
      {:ok, user} ->
        conn
        |> AuthPlug.login(user)
        |> AuthPlug.remember(user)
        |> put_flash(:info, "Welcome to the Sample App!")
        |> redirect(to: ~p"/users/#{user.id}")
      _ ->
        conn
        |> put_flash(:error, "Invalid credentials")
        |> render(:login, changeset: Accounts.change_user(%Accounts.User{}))
    end
  end

  def delete(conn, _params) do
    conn
    |> AuthPlug.logout()
    |> redirect(to: ~p"/")
  end
end
