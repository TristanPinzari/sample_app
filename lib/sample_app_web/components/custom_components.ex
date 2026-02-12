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
            <summary class="list-none cursor-pointer"><.icon name="hero-user-solid" class="h-7 w-7" /></summary>
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
    gravatar_id =
      assigns.user.email
      |> String.downcase()
      |> then(&:crypto.hash(:md5, &1))
      |> Base.encode16(case: :lower)

      assigns = assign(assigns, :url, "https://secure.gravatar.com/avatar/#{gravatar_id}")
    ~H"""
      <img class="w-40 rounded-full" src={@url} alt={@user.name} class="gravatar" />
    """
  end
end
