defmodule SampleAppWeb.MicropostPlug do
  import Plug.Conn
  alias SampleApp.Accounts

  def init(opts), do: opts

  def call(conn, _opts) do
    cond do
      conn.assigns[:current_user] ->
        assign(
          conn,
          :current_user,
          Accounts.preload_microposts(conn.assigns.current_user)
        )

      true ->
        conn
    end
  end
end
