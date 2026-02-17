defmodule SampleAppWeb.MicropostController do
  use SampleAppWeb, :controller
  alias SampleApp.Posts
  alias SampleApp.Posts.Micropost

  plug :logged_in_user when action in [:index, :create, :delete]
  plug SampleAppWeb.MicropostPlug when action in [:create, :index]

  def index(conn, _params) do
  end

  def create(conn, %{"micropost" => micropost_params}) do
    IO.inspect(micropost_params)
    case Posts.create_micropost(
           Map.take(micropost_params, ["content"]),
           conn.assigns.current_user
         ) do
      {:ok, %Micropost{}} ->
        IO.puts("1----------------------")
        conn
        |> put_flash(:info, "Micropost created!")
        |> redirect(to: ~p"/")

      {:error, %Ecto.Changeset{} = changeset} ->
        IO.inspect(changeset, label: "2----------------------")
        page_data = SampleAppWeb.HelperFunctions.params_to_page_data()

        conn
        |> assign(:page_title, "Home")
        |> render(:home, changeset: changeset, posts: page_data.posts, page: page_data.current_page, total_pages: page_data.total_pages)
    end
  end

  def delete(conn, _params) do
  end
end
