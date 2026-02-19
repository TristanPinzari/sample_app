defmodule SampleAppWeb.RelationshipController do
  use SampleAppWeb, :controller
  alias SampleApp.Relationships

  plug :logged_in_user when action in [:create, :delete]

  def create(conn, %{"user_id" => followed_id, "user_name" => followed_name}) do
    case Relationships.follow(conn.assigns.current_user, followed_id) do
      {:ok, _} ->
        conn
        |> put_flash(:info, "You are now following #{followed_name}")
        |> redirect(to: ~p"/users/#{followed_id}")

      _ ->
        conn
        |> put_flash(:error, "Something went wrong")
        |> redirect(to: ~p"/users/#{followed_id}")
    end
  end

  def delete(conn, %{"user_id" => followed_id, "user_name" => followed_name}) do
    case Relationships.unfollow(conn.assigns.current_user.id, followed_id) do
      {:ok, _} ->
        conn
        |> put_flash(:info, "You unfollowed #{followed_name}")
        |> redirect(to: ~p"/users/#{followed_id}")

      _ ->
        conn
        |> put_flash(:error, "Something went wrong")
        |> redirect(to: ~p"/users/#{followed_id}")
    end
  end
end
