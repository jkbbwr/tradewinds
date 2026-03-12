defmodule TradewindsWeb.ShipController do
  use TradewindsWeb, :controller
  use Goal
  use OpenApiSpex.ControllerSpecs

  alias Tradewinds.Fleet

  alias TradewindsWeb.Schemas.{
    ShipsResponse,
    ShipResponse,
    RenameShipRequest,
    TransitRequest,
    TransitLogsResponse,
    TransferToWarehouseRequest,
    ErrorResponse,
    ChangesetResponse
  }

  action_fallback TradewindsWeb.FallbackController

  # -- Ships --

  defparams :ships do
    optional(:after, :string)
    optional(:before, :string)
    optional(:limit, :integer, min: 1, max: 100)
  end

  operation(:ships,
    operation_id: "ships",
    tags: ["Fleet"],
    summary: "List company ships",
    description: "Returns a list of ships owned by the current company.",
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
      ok: {"List of ships", "application/json", ShipsResponse},
      unauthorized: {"Invalid or expired token", "application/json", ErrorResponse}
    ]
  )

  def ships(conn, params) do
    with {:ok, valid} <- validate(:ships, params) do
      page = Fleet.list_ships(conn.assigns.scope, valid)
      render(conn, :index, page: page)
    end
  end

  # -- Ship --

  operation(:ship,
    operation_id: "ship",
    tags: ["Fleet"],
    summary: "Get ship details",
    description: "Returns the details of a specific ship owned by the current company.",
    security: [%{"bearerAuth" => []}],
    parameters: [
      %OpenApiSpex.Parameter{
        name: "tradewinds-company-id",
        in: :header,
        required: true,
        schema: %OpenApiSpex.Schema{type: :string, format: :uuid},
        description: "Company ID"
      },
      ship_id: [in: :path, description: "Ship ID", type: :string]
    ],
    responses: [
      ok: {"Ship details", "application/json", ShipResponse},
      unauthorized: {"Invalid or expired token", "application/json", ErrorResponse},
      not_found: {"Ship not found", "application/json", ErrorResponse}
    ]
  )

  def ship(conn, %{"ship_id" => ship_id}) do
    with {:ok, ship} <- Fleet.fetch_company_ship(conn.assigns.scope, ship_id) do
      render(conn, :show, ship: ship)
    end
  end

  # -- Transit Logs --

  defparams :transit_logs do
    optional(:after, :string)
    optional(:before, :string)
    optional(:limit, :integer, min: 1, max: 100)
  end

  operation(:transit_logs,
    operation_id: "transitLogs",
    tags: ["Fleet"],
    summary: "List transit logs for a ship",
    description:
      "Returns a paginated list of transit logs for a specific ship owned by the current company.",
    security: [%{"bearerAuth" => []}],
    parameters: [
      %OpenApiSpex.Parameter{
        name: "tradewinds-company-id",
        in: :header,
        required: true,
        schema: %OpenApiSpex.Schema{type: :string, format: :uuid},
        description: "Company ID"
      },
      ship_id: [in: :path, description: "Ship ID", type: :string],
      after: [in: :query, description: "Cursor for next page", type: :string],
      before: [in: :query, description: "Cursor for previous page", type: :string],
      limit: [in: :query, description: "Number of items per page", type: :integer]
    ],
    responses: [
      ok: {"List of transit logs", "application/json", TransitLogsResponse},
      unauthorized: {"Invalid or expired token", "application/json", ErrorResponse},
      not_found: {"Ship not found", "application/json", ErrorResponse}
    ]
  )

  def transit_logs(conn, params = %{"ship_id" => ship_id}) do
    with {:ok, valid} <- validate(:transit_logs, params),
         {:ok, page} <- Fleet.list_transit_logs(conn.assigns.scope, ship_id, valid) do
      render(conn, :transit_logs, page: page)
    end
  end

  # -- Rename Ship --

  defparams :rename_ship do
    required(:name, :string)
  end

  operation(:rename_ship,
    operation_id: "renameShip",
    tags: ["Fleet"],
    summary: "Rename a ship",
    description: "Changes the name of a ship owned by the current company.",
    security: [%{"bearerAuth" => []}],
    parameters: [
      %OpenApiSpex.Parameter{
        name: "tradewinds-company-id",
        in: :header,
        required: true,
        schema: %OpenApiSpex.Schema{type: :string, format: :uuid},
        description: "Company ID"
      },
      ship_id: [in: :path, description: "Ship ID", type: :string]
    ],
    request_body: {"Rename details", "application/json", RenameShipRequest},
    responses: [
      ok: {"Ship renamed", "application/json", ShipResponse},
      unprocessable_entity: {"Validation error", "application/json", ChangesetResponse},
      unauthorized: {"Invalid or expired token", "application/json", ErrorResponse},
      not_found: {"Ship not found", "application/json", ErrorResponse}
    ]
  )

  def rename_ship(conn, params = %{"ship_id" => ship_id}) do
    with {:ok, valid} <- validate(:rename_ship, params),
         {:ok, ship} <- Fleet.rename_ship(conn.assigns.scope, ship_id, valid.name) do
      render(conn, :show, ship: ship)
    end
  end

  # -- Transit --

  defparams :transit do
    required(:route_id, :string, format: :uuid)
  end

  operation(:transit,
    operation_id: "transit",
    tags: ["Fleet"],
    summary: "Transit a ship",
    description: "Puts a ship in transit along a specific route.",
    security: [%{"bearerAuth" => []}],
    parameters: [
      %OpenApiSpex.Parameter{
        name: "tradewinds-company-id",
        in: :header,
        required: true,
        schema: %OpenApiSpex.Schema{type: :string, format: :uuid},
        description: "Company ID"
      },
      ship_id: [in: :path, description: "Ship ID", type: :string]
    ],
    request_body: {"Transit details", "application/json", TransitRequest},
    responses: [
      ok: {"Ship in transit", "application/json", ShipResponse},
      unprocessable_entity: {"Validation error", "application/json", ChangesetResponse},
      unauthorized: {"Invalid or expired token", "application/json", ErrorResponse},
      not_found: {"Ship not found", "application/json", ErrorResponse}
    ]
  )

  def transit(conn, params = %{"ship_id" => ship_id}) do
    with {:ok, valid} <- validate(:transit, params),
         {:ok, ship} <- Fleet.transit_ship(conn.assigns.scope, ship_id, valid.route_id) do
      render(conn, :show, ship: ship)
    end
  end

  # -- Transfer to Warehouse --

  defparams :transfer_to_warehouse do
    required(:warehouse_id, :string, format: :uuid)
    required(:good_id, :string, format: :uuid)
    required(:quantity, :integer, min: 1)
  end

  operation(:transfer_to_warehouse,
    operation_id: "transferToWarehouse",
    tags: ["Fleet"],
    summary: "Transfer cargo to warehouse",
    description: "Transfers cargo from a docked ship to a warehouse.",
    security: [%{"bearerAuth" => []}],
    parameters: [
      %OpenApiSpex.Parameter{
        name: "tradewinds-company-id",
        in: :header,
        required: true,
        schema: %OpenApiSpex.Schema{type: :string, format: :uuid},
        description: "Company ID"
      },
      ship_id: [in: :path, description: "Ship ID", type: :string]
    ],
    request_body: {"Transfer details", "application/json", TransferToWarehouseRequest},
    responses: [
      no_content: "Cargo transferred successfully",
      unprocessable_entity: {"Validation error", "application/json", ChangesetResponse},
      unauthorized: {"Invalid or expired token", "application/json", ErrorResponse},
      not_found: {"Ship not found", "application/json", ErrorResponse}
    ]
  )

  def transfer_to_warehouse(conn, params = %{"ship_id" => ship_id}) do
    with {:ok, valid} <- validate(:transfer_to_warehouse, params),
         {:ok, :transferred} <-
           Fleet.transfer_to_warehouse(
             conn.assigns.scope,
             ship_id,
             valid.warehouse_id,
             valid.good_id,
             valid.quantity
           ) do
      send_resp(conn, :no_content, "")
    end
  end
end
