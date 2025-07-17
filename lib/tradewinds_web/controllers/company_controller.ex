defmodule TradewindsWeb.CompanyController do
  @moduledoc """
  Controller for handling company-related requests.
  """
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

  @doc """
  Creates a new company.
  """
  def create(conn, params) do
    with {:ok, attrs} <- validate(:create, params),
         {:ok, company} <-
           Companies.create_company(
             attrs.name,
             attrs.ticker,
             20000,
             attrs.home_port_id,
             attrs.directors || []
           ) do
      conn
      |> put_status(:created)
      |> render(:create, %{company: company})
    end
  end
end
