defmodule TradewindsWeb.Plugs.CompanyContext do
  import Plug.Conn

  alias Tradewinds.Companies
  alias Tradewinds.Scope

  def init(opts), do: opts

  def call(conn, _opts) do
    scope =
      conn.assigns[:scope] ||
        raise """
        CompanyContext expects `conn.assigns.scope` to exist!
        Did you forget to run the `Auth` plug first?
        """

    case get_req_header(conn, "tradewinds-company-id") do
      [company_id] ->
        if Companies.player_is_director?(scope.player, company_id) do
          assign(conn, :scope, Scope.put_company_id(scope, company_id))
        else
          conn
          |> put_status(:forbidden)
          |> Phoenix.Controller.json(%{error: "You are not authorized for this company."})
          |> halt()
        end

      [] ->
        conn
        |> put_status(:bad_request)
        |> Phoenix.Controller.json(%{error: "Missing tradewinds-company-id header."})
        |> halt()
    end
  end
end
