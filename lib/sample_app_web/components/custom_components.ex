defmodule SampleAppWeb.CustomComponents do
  use SampleAppWeb, :html

  def nav(assigns) do
    ~H"""
    <nav class="flex justify-between p-10 items-center">
      <h1 class="text-4xl font-semibold">Sample App</h1>

      <div class="flex items-center gap-12">
        <ul class="flex items-center gap-5 *:my-auto *:cursor-pointer *:hover:text-orange-500 font-extralight *:duration-250">
          <li><.link href={~p"/"}>Home</.link></li>

          <li><.link href={~p"/about"}>About</.link></li>

          <li><.link href={~p"/help"}>Help</.link></li>

          <li><.link href={~p"/contact"}>Contact</.link></li>
        </ul>

        <%= if @login and !@current_user do %>
          <.link navigate={~p"/login"}>
            <button class="bg-white text-black rounded-full py-2 px-8 text-lg cursor-pointer shadow-xl">
              Log in
            </button>
          </.link>
        <% else %>
          <details class="relative mr-5">
            <summary class="list-none cursor-pointer">
              <.icon name="hero-user-solid" class="h-7 w-7" />
            </summary>

            <div class="absolute left-[50%] translate-x-[-50%] mt-2 w-20 rounded-lg py-1 bg-main-bg border border-main-border flex flex-col [&_a]:text-center gap-1">
              <.link href={~p"/users/#{@current_user.id}"}>Profile</.link>
              <.link>Settings</.link>
              <.link href={~p"/logout"} method="delete">Log out</.link>
            </div>
          </details>
        <% end %>
      </div>
    </nav>
    """
  end

  def gravatar(assigns) do
    size = assigns[:size] || 200

    gravatar_id =
      assigns.user.email
      |> String.downcase()
      |> then(&:crypto.hash(:md5, &1))
      |> Base.encode16(case: :lower)

    url =
      if assigns.user.avatar do
        SampleApp.Avatar.url({assigns.user.avatar, assigns.user})
      else
        "https://secure.gravatar.com/avatar/#{gravatar_id}?s=#{size}"
      end

    assigns = assign(assigns, url: url, size: size)

    ~H"""
    <img
      src={@url}
      alt={@user.name}
      class="rounded-full shadow-sm object-cover"
      style={"width: #{@size}px; height: #{@size}px;"}
    />
    """
  end

  defp time_to_words(insertion_time) do
    insertion_date_time = Timex.to_datetime(insertion_time)

    diff_in_minutes =
      Timex.diff(
        Timex.now(),
        insertion_date_time,
        :minutes
      )

    {:ok, diff_in_minutes_words} =
      Timex.shift(
        insertion_date_time,
        minutes: -diff_in_minutes
      )
      |> Timex.format("{relative}", :relative)

    diff_in_minutes_words
  end

  def micropost(assigns) do
    time_stamp = time_to_words(assigns.micropost.inserted_at)
    user = assigns[:user] || assigns.micropost.user
    current_user_id = assigns[:current_user_id]

    assigns =
      assign(assigns, time_stamp: time_stamp, user: user, current_user_id: current_user_id)

    ~H"""
    <div class="border-t py-3 flex flex-col gap-3">
      <.link href={~p"/users/#{@user.id}"} class="flex items-center gap-5">
        <.gravatar user={@user} size={50} />
        <p>{@user.name}</p>
      </.link>
      <div class="flex flex-col gap-2 flex-1 ml-15 pl-3 border-l">
        <p>{@micropost.content}</p>
        <%= if @micropost.image do %>
          <.link href={"#{SampleApp.Image.url({@micropost.image, @micropost})}"}>
            <img
              src={"#{SampleApp.Image.url({@micropost.image, @micropost})}"}
              alt={"#{SampleApp.Image.url({@micropost.image, @micropost})}"}
              class="object-contain max-h-50"
            />
          </.link>
        <% end %>
      </div>
      <div class="flex gap-5 items-center">
        <p class="text-white/50">{@time_stamp}</p>
        <%= if @current_user_id && @current_user_id == @user.id do %>
          <.link
            class="link"
            href={~p"/users/#{@current_user_id}/microposts/#{@micropost.id}"}
            method="delete"
            data-confirm="Are you sure you want to delete this post?"
          >
            delete
          </.link>
        <% end %>
      </div>
    </div>
    """
  end

  def user(assigns) do
    micropost_count = SampleApp.Posts.count_user_microposts(assigns.user.id)
    following_count = SampleApp.Relationships.follower_count(assigns.user)
    follower_count = SampleApp.Relationships.following_count(assigns.user)

    assigns =
      assign(assigns, %{
        micropost_count: micropost_count,
        following_count: following_count,
        follower_count: follower_count
      })

    ~H"""
    <div class="flex items-center gap-3 border-t border-t-white/25 py-4 justify-between">
      <.link href={~p"/users/#{@user.id}"} class="flex items-center gap-5">
        <.gravatar user={@user} size={75} />
        <div>
          <p>{@user.name}</p>
          <p>
            Posts: {@micropost_count} | Following: {@following_count} | Followers: {@follower_count}
          </p>
        </div>
      </.link>
      <%= if @current_user.admin && @current_user.id != @user.id && assigns[:admin] do %>
        <.link
          href={~p"/users/#{@user.id}"}
          method="delete"
          data-confirm="Are you sure?"
          class="text-red-600 hover:underline"
        >
          delete user
        </.link>
      <% end %>
    </div>
    """
  end
end
