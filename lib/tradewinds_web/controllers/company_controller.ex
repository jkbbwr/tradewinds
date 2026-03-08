defmodule TradewindsWeb.CompanyController do
  use TradewindsWeb, :controller

  action_fallback TradewindsWeb.FallbackController

  def companies(conn, _params) do
    # TODO: Implement retrieving player's companies
    send_resp(conn, 501, "Not Implemented")
  end

  def create_company(conn, _params) do
    # TODO: Implement company creation
    send_resp(conn, 501, "Not Implemented")
  end

  def company(conn, _params) do
    # TODO: Implement fetching current company details
    send_resp(conn, 501, "Not Implemented")
  end

  def economy(conn, _params) do
    # TODO: Implement fetching company economy details/ledger
    send_resp(conn, 501, "Not Implemented")
  end
end
