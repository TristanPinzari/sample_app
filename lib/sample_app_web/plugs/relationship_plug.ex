defmodule SampleAppWeb.RelationshipPlug do
  import Plug.Conn

  alias SampleApp.Relationships
  alias SampleApp.Accounts

  def init(opts), do: opts

  def call(conn, _opts) do
    if conn.assigns[:current_user] do
      user_id = conn.params["id"] || conn.params["user_id"]

      user_on_page =
        if user_id do
          Accounts.get_user(user_id)
        else
          conn.assigns.current_user
        end

      conn =
        conn
        |> assign(
          :following_count,
          Relationships.following_count(user_on_page)
        )
        |> assign(
          :follower_count,
          Relationships.follower_count(user_on_page)
        )
        |> assign(
          :micropost_count,
          SampleApp.Posts.count_user_microposts(user_on_page.id)
        )

      if user_id do
        is_follower =
          Relationships.follower?(
            Accounts.get_user!(user_id),
            conn.assigns.current_user
          )

        conn
        |> assign(:non_follower, !is_follower)
        |> assign(:follower, is_follower)
      else
        conn
      end
    else
      conn
    end
  end
end
