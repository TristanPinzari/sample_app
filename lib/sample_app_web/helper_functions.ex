defmodule SampleAppWeb.HelperFunctions do
  alias SampleApp.Posts

  def params_to_page_data(params \\ %{}) do
    posts =
      case params do
        %{user: user} when not is_nil(user) ->
          SampleApp.Relationships.microposts_for_feed(user)

        _else ->
          Posts.list_microposts(params)
          |> SampleApp.Repo.preload([:user])
      end

    total_count = Posts.count_microposts()

    current_page = String.to_integer(params["page"] || "1")
    total_pages = Float.ceil(total_count / 10) |> round()

    %{
      posts: posts,
      total_count: total_count,
      current_page: current_page,
      total_pages: total_pages
    }
  end

  def get_last_url(conn) do
    conn
    |> Plug.Conn.get_req_header("referer")
    |> List.first()
  end
end
