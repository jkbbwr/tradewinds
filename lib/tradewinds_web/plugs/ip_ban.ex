defmodule TradewindsWeb.Plugs.IPBan do
  import Plug.Conn

  alias Tradewinds.Accounts

  def init(opts), do: opts

  def call(conn, _opts) do
    ip = conn.remote_ip |> :inet.ntoa() |> to_string()

    if Accounts.is_ip_banned?(ip) do
      conn
      |> put_status(:forbidden)
      |> Phoenix.Controller.json(%{error: "IP address is banned"})
      |> halt()
    else
      conn
    end
  end
end
