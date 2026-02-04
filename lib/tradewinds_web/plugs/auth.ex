defmodule TradewindsWeb.Plugs.Auth do
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    with ["Bearer " <> token] <- get_req_header(conn, "authorization"),
         {:ok, token} <- Tradewinds.Auth.validate(token) do
      assign(conn, :current_player, token.player)
    else
      _ ->
        conn
        |> put_status(:unauthorized)
        |> Phoenix.Controller.json(%{error: %{message: "Unauthorized"}})
        |> halt()
    end
  end
end
