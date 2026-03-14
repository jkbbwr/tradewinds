defmodule TradewindsWeb.PageController do
  use TradewindsWeb, :controller

  import Ecto.Query

  def home(conn, _params) do
    companies_count = Tradewinds.Repo.aggregate(Tradewinds.Companies.Company, :count)

    ships_at_sea =
      Tradewinds.Repo.aggregate(
        from(s in Tradewinds.Fleet.Ship, where: s.status == :traveling),
        :count
      )

    render(conn, :home, companies_count: companies_count, ships_at_sea: ships_at_sea)
  end
end
