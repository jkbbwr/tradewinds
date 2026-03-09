defmodule TradewindsWeb.Plugs.Auth do
  import Plug.Conn

  alias Tradewinds.Scope

  def init(opts), do: opts

  def call(conn, _opts) do
    with ["Bearer " <> token] <- get_req_header(conn, "authorization"),
         {:ok, token} <- Tradewinds.Accounts.validate(token) do
      conn
      |> assign(:scope, Scope.for_player(token.player))
      |> assign(:token, token)
    else
      _ ->
        conn
        |> put_status(:unauthorized)
        |> Phoenix.Controller.json(%{error: %{message: "Unauthorized"}})
        |> halt()
    end
  end
end
