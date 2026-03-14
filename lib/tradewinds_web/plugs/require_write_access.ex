defmodule TradewindsWeb.Plugs.RequireWriteAccess do
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    if conn.assigns.scope.read_only do
      conn
      |> put_status(:forbidden)
      |> Phoenix.Controller.json(%{error: %{message: "Token is read-only"}})
      |> halt()
    else
      conn
    end
  end
end
