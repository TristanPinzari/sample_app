defmodule SampleAppWeb.PageController do
  use SampleAppWeb, :controller

  plug SampleAppWeb.MicropostPlug when action in [:home]
  plug SampleAppWeb.RelationshipPlug when action in [:home]
  alias SampleApp.Posts

  def home(conn, params) do
    page_data =
      SampleAppWeb.HelperFunctions.params_to_page_data(
        Map.put(params, :user, conn.assigns[:current_user])
      )

    conn
    |> assign(:page_title, "Home")
    |> render(:home,
      changeset: Posts.change_micropost(%Posts.Micropost{}),
      posts: page_data.posts,
      page: page_data.current_page,
      total_pages: page_data.total_pages
    )
  end

  def help(conn, _params) do
    conn
    |> assign(:page_title, "Help")
    |> render(:help)
  end

  def about(conn, _params) do
    conn
    |> assign(:page_title, "About")
    |> render(:about)
  end

  def contact(conn, _params) do
    conn
    |> assign(:page_title, "Contact")
    |> render(:contact)
  end
end
