defmodule SampleAppWeb.AuthPlug do
  use SampleAppWeb, :verified_routes
  import Plug.Conn
  import Phoenix.Controller
  alias SampleApp.Accounts

  def init(opts), do: opts

  def call(conn, _opts) do
    cond do
      user_id = get_session(conn, :user_id) ->
        assign(conn, :current_user, Accounts.get_user(user_id))

      token = conn.cookies["remember_token"] ->
        case SampleApp.Token.verify_remember_token(token) do
          {:ok, user_id} ->
            if user = Accounts.get_user(user_id) do
              login(conn, user)
            else
              logout(conn)
            end

          {:error, _reason} ->
            logout(conn)
        end

      true ->
        assign(conn, :current_user, nil)
    end
  end

  def login(conn, user) do
    conn
    |> assign(:current_user, user)
    |> put_session(:user_id, user.id)
    |> configure_session(renew: true)
  end

  def logout(conn) do
    conn
    |> delete_resp_cookie("remember_token")
    |> configure_session(drop: true)
    |> assign(:current_user, nil)
  end

  def remember(conn, user) do
    token = SampleApp.Token.gen_remember_token(user)
    put_resp_cookie(conn, "remember_token", token, max_age: 2_629_746)
  end

  def logged_in_user(conn, _opts) do
    if conn.assigns.current_user do
      conn
    else
      conn
      |> store_location()
      |> put_flash(:error, "Please log in.")
      |> redirect(to: ~p"/login")
      |> halt()
    end
  end

  def correct_user(conn, _opts) do
    user_id = String.to_integer(conn.params["id"])

    if user_id == conn.assigns.current_user.id do
      conn
    else
      conn
      |> put_flash(:error, "You are not authorized there")
      |> redirect(to: ~p"/")
      |> halt()
    end
  end

  def is_admin(conn, _opts) do
    user = conn.assigns.current_user

    if user && user.admin do
      conn
    else
      conn
      |> put_flash(:error, "You are not authorized there")
      |> redirect(to: ~p"/")
      |> halt()
    end
  end

  def redirect_back_or(conn, default) do
    path = get_session(conn, :forward_url) || default

    conn
    |> delete_session(:forward_url)
    |> redirect(to: path)
  end

  def store_location(conn) do
    case conn do
      %Plug.Conn{method: "GET"} ->
        put_session(conn, :forward_url, conn.request_path)

      _ ->
        conn
    end
  end
end
