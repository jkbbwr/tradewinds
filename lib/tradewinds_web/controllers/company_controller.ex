defmodule TradewindsWeb.CompanyController do
  use TradewindsWeb, :controller
  use Goal
  use OpenApiSpex.ControllerSpecs

  alias Tradewinds.Companies
  alias TradewindsWeb.Schemas.{
    CompaniesResponse,
    CompanyResponse,
    CreateCompanyRequest,
    CompanyEconomyResponse,
    LedgerResponse,
    ErrorResponse,
    ChangesetResponse
  }

  action_fallback TradewindsWeb.FallbackController

  operation(:companies,
    summary: "List player's companies",
    description: "Returns a list of companies where the current player is a director.",
    security: [%{"bearerAuth" => []}],
    responses: [
      ok: {"List of companies", "application/json", CompaniesResponse},
      unauthorized: {"Invalid or expired token", "application/json", ErrorResponse}
    ]
  )

  def companies(conn, _params) do
    companies = Companies.list_player_companies(conn.assigns.scope)
    render(conn, :index, companies: companies)
  end

  defparams :create_company do
    required(:name, :string)
    required(:ticker, :string)
    required(:home_port_id, :string, format: :uuid)
  end

  operation(:create_company,
    summary: "Create a new company",
    description: "Creates a new company and assigns the player as its first director.",
    security: [%{"bearerAuth" => []}],
    request_body: {"Company details", "application/json", CreateCompanyRequest},
    responses: [
      created: {"Company created", "application/json", CompanyResponse},
      unprocessable_entity: {"Validation error", "application/json", ChangesetResponse},
      unauthorized: {"Invalid or expired token", "application/json", ErrorResponse}
    ]
  )

  def create_company(conn, params) do
    with {:ok, valid} <- validate(:create_company, params),
         {:ok, company} <-
           Companies.create(conn.assigns.scope, valid.name, valid.ticker, valid.home_port_id) do
      conn
      |> put_status(:created)
      |> render(:show, company: company)
    end
  end

  operation(:company,
    summary: "Get current company",
    description:
      "Returns the details of the company specified in the 'tradewinds-company-id' header.",
    security: [%{"bearerAuth" => []}],
    parameters: [
      %OpenApiSpex.Parameter{
        name: "tradewinds-company-id",
        in: :header,
        required: true,
        schema: %OpenApiSpex.Schema{type: :string, format: :uuid},
        description: "Company ID"
      }
    ],
    responses: [
      ok: {"Company details", "application/json", CompanyResponse},
      unauthorized: {"Invalid or expired token", "application/json", ErrorResponse},
      forbidden: {"Not a director of this company", "application/json", ErrorResponse}
    ]
  )

  def company(conn, _params) do
    with {:ok, company} <- Companies.fetch_company(conn.assigns.scope.company_id) do
      render(conn, :show, company: company)
    end
  end

  operation(:economy,
    summary: "Get company economy summary",
    description: "Returns financial summary and upkeep information for the current company.",
    security: [%{"bearerAuth" => []}],
    parameters: [
      %OpenApiSpex.Parameter{
        name: "tradewinds-company-id",
        in: :header,
        required: true,
        schema: %OpenApiSpex.Schema{type: :string, format: :uuid},
        description: "Company ID"
      }
    ],
    responses: [
      ok: {"Economy summary", "application/json", CompanyEconomyResponse},
      unauthorized: {"Invalid or expired token", "application/json", ErrorResponse},
      forbidden: {"Not a director of this company", "application/json", ErrorResponse}
    ]
  )

  def economy(conn, _params) do
    company_id = conn.assigns.scope.company_id

    with {:ok, company} <- Companies.fetch_company(company_id) do
      ship_upkeep = Tradewinds.Fleet.calculate_total_upkeep(company_id)
      warehouse_upkeep = Tradewinds.Logistics.calculate_total_upkeep(company_id)

      render(conn, :economy,
        treasury: company.treasury,
        reputation: company.reputation,
        ship_upkeep: ship_upkeep,
        warehouse_upkeep: warehouse_upkeep,
        total_upkeep: ship_upkeep + warehouse_upkeep
      )
    end
  end

  defparams :ledger do
    optional(:after, :string)
    optional(:before, :string)
    optional(:limit, :integer, min: 1, max: 100)
  end

  operation(:ledger,
    summary: "Get company ledger",
    description: "Returns the financial ledger entries for the current company, ordered by most recent first.",
    security: [%{"bearerAuth" => []}],
    parameters: [
      %OpenApiSpex.Parameter{
        name: "tradewinds-company-id",
        in: :header,
        required: true,
        schema: %OpenApiSpex.Schema{type: :string, format: :uuid},
        description: "Company ID"
      },
      after: [in: :query, description: "Cursor for next page", type: :string],
      before: [in: :query, description: "Cursor for previous page", type: :string],
      limit: [in: :query, description: "Number of items per page", type: :integer]
    ],
    responses: [
      ok: {"Company ledger", "application/json", LedgerResponse},
      unauthorized: {"Invalid or expired token", "application/json", ErrorResponse},
      forbidden: {"Not a director of this company", "application/json", ErrorResponse}
    ]
  )

  def ledger(conn, params) do
    with {:ok, valid} <- validate(:ledger, params) do
      company_id = conn.assigns.scope.company_id

      opts = Map.take(valid, [:after, :before, :limit]) |> Map.to_list()
      page = Companies.list_ledger(company_id, opts)
      render(conn, :ledger, page: page)
    end
  end
end
