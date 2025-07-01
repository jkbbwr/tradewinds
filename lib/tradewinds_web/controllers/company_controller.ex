defmodule TradewindsWeb.CompanyController do
  use TradewindsWeb, :controller

  alias Tradewinds.Companies

  use Goal

  action_fallback TradewindsWeb.FallbackController

  defparams :create do
    required(:name, :string)
    required(:ticker, :string)
    required(:home_port_id, :string)
    required(:directors, {:array, :string})
  end

  def fuck(conn, _params) do
    Tradewinds.Repo.get!(Tradewinds.Schema.Company, Ecto.UUID.generate())
  end

  def create(conn, params) do
    with {:ok, attrs} <- validate(:create, params),
         {:ok, company} <-
           Companies.create_company(
             attrs.name,
             attrs.ticker,
             1000,
             attrs.home_port_id,
             attrs.directors || []
           ) do
      conn
      |> put_status(:created)
      |> render(:create, %{company: company})
    end
  end
end
