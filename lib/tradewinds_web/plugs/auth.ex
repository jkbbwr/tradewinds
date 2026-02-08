defmodule TradewindsWeb.Plugs.Auth do
  import Plug.Conn

  alias Tradewinds.Scope

  def init(opts), do: opts

  def call(conn, _opts) do
    with ["Bearer " <> token] <- get_req_header(conn, "authorization"),
         {:ok, token} <- Tradewinds.Accounts.validate(token) do
      scope = Scope.for(player: token.player)
      assign(conn, :current_scope, scope)
    else
      _ ->
        conn
        |> put_status(:unauthorized)
        |> Phoenix.Controller.json(%{error: %{message: "Unauthorized"}})
        |> halt()
    end
  end
end
