defmodule SampleAppWeb.UserController do
  use SampleAppWeb, :controller
  alias SampleApp.Accounts

  plug :logged_in_user when action in [:index, :edit, :update, :delete]
  plug :correct_user when action in [:edit, :update]
  plug :is_admin when action in [:delete]

  def index(conn, params) do
    users = Accounts.list_users(params)
    total_count = Accounts.count_users()

    current_page = String.to_integer(params["page"] || "1")
    total_pages = Float.ceil(total_count / 10) |> round()

    conn
    |> assign(:page_title, "Users")
    |> render(:index, users: users, page: current_page, total_pages: total_pages)
  end

  def sign_up(conn, _params) do
    conn
    |> assign(:page_title, "Sign up")
    |> render(:sign_up, changeset: Accounts.change_user(%Accounts.User{}))
  end

  def create(conn, %{"user" => user_params}) do
    case Accounts.create_user(user_params) do
      {:ok, user} ->
        Accounts.send_user_activation_email(user)

        conn
        |> put_flash(:info, "Please check your email to activate your account.")
        |> redirect(to: ~p"/")

      # conn
      # |> SampleAppWeb.AuthPlug.login(user)
      # |> put_flash(:info, "Welcome to the Sample App!")
      # |> redirect(to: ~p"/users/#{user.id}")

      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> render(:sign_up, changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)

    conn
    |> assign(:page_title, user.name)
    |> render(:show, user: user)
  end

  def edit(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)
    changeset = Accounts.change_user(user)
    render(conn, :edit, user: user, changeset: changeset)
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    user = Accounts.get_user!(id)

    case Accounts.update_user_identity(user, user_params) do
      {:ok, _user} ->
        conn
        |> put_flash(:info, "Profile updated")
        |> redirect(to: ~p"/users/#{id}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, user: user, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    user = Accounts.get_user(id)

    if user do
      Accounts.delete_user(user)

      conn
      |> put_flash(:info, "User deleted")
      |> redirect(to: ~p"/users")
    else
      conn
      |> put_flash(:error, "User does not exist")
      |> redirect(to: ~p"/users")
    end
  end
end
