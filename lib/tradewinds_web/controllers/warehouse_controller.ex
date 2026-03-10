defmodule TradewindsWeb.WarehouseController do
  use TradewindsWeb, :controller
  use Goal
  use OpenApiSpex.ControllerSpecs

  alias Tradewinds.Logistics
  alias TradewindsWeb.Schemas.{
    WarehousesResponse,
    WarehouseResponse,
    TransferToShipRequest,
    ErrorResponse,
    ChangesetResponse
  }

  action_fallback TradewindsWeb.FallbackController

  # -- Warehouses --

  operation(:warehouses,
    summary: "List company warehouses",
    description: "Returns a list of warehouses owned by the current company.",
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
      ok: {"List of warehouses", "application/json", WarehousesResponse},
      unauthorized: {"Invalid or expired token", "application/json", ErrorResponse}
    ]
  )

  def warehouses(conn, _params) do
    warehouses = Logistics.list_warehouses(conn.assigns.scope)
    render(conn, :index, warehouses: warehouses)
  end

  # -- Warehouse --

  operation(:warehouse,
    summary: "Get warehouse details",
    description: "Returns the details of a specific warehouse owned by the current company.",
    security: [%{"bearerAuth" => []}],
    parameters: [
      %OpenApiSpex.Parameter{
        name: "tradewinds-company-id",
        in: :header,
        required: true,
        schema: %OpenApiSpex.Schema{type: :string, format: :uuid},
        description: "Company ID"
      },
      warehouse_id: [in: :path, description: "Warehouse ID", type: :string]
    ],
    responses: [
      ok: {"Warehouse details", "application/json", WarehouseResponse},
      unauthorized: {"Invalid or expired token", "application/json", ErrorResponse},
      not_found: {"Warehouse not found", "application/json", ErrorResponse}
    ]
  )

  def warehouse(conn, %{"warehouse_id" => warehouse_id}) do
    with {:ok, warehouse} <- Logistics.fetch_company_warehouse(conn.assigns.scope, warehouse_id) do
      render(conn, :show, warehouse: warehouse)
    end
  end

  # -- Grow --

  operation(:grow,
    summary: "Upgrade a warehouse",
    description: "Upgrades a warehouse to the next tier, increasing its capacity.",
    security: [%{"bearerAuth" => []}],
    parameters: [
      %OpenApiSpex.Parameter{
        name: "tradewinds-company-id",
        in: :header,
        required: true,
        schema: %OpenApiSpex.Schema{type: :string, format: :uuid},
        description: "Company ID"
      },
      warehouse_id: [in: :path, description: "Warehouse ID", type: :string]
    ],
    responses: [
      ok: {"Warehouse upgraded successfully", "application/json", WarehouseResponse},
      unprocessable_entity: {"Validation error", "application/json", ChangesetResponse},
      unauthorized: {"Invalid or expired token", "application/json", ErrorResponse},
      forbidden: {"Insufficient funds or unauthorized", "application/json", ErrorResponse},
      not_found: {"Warehouse not found", "application/json", ErrorResponse}
    ]
  )

  def grow(conn, %{"warehouse_id" => warehouse_id}) do
    with {:ok, warehouse} <- Logistics.grow_warehouse(conn.assigns.scope, warehouse_id) do
      render(conn, :show, warehouse: warehouse)
    end
  end

  # -- Shrink --

  operation(:shrink,
    summary: "Downgrade a warehouse",
    description: "Downgrades a warehouse to the previous tier, decreasing its capacity.",
    security: [%{"bearerAuth" => []}],
    parameters: [
      %OpenApiSpex.Parameter{
        name: "tradewinds-company-id",
        in: :header,
        required: true,
        schema: %OpenApiSpex.Schema{type: :string, format: :uuid},
        description: "Company ID"
      },
      warehouse_id: [in: :path, description: "Warehouse ID", type: :string]
    ],
    responses: [
      ok: {"Warehouse downgraded successfully", "application/json", WarehouseResponse},
      unprocessable_entity: {"Validation error", "application/json", ChangesetResponse},
      unauthorized: {"Invalid or expired token", "application/json", ErrorResponse},
      not_found: {"Warehouse not found", "application/json", ErrorResponse}
    ]
  )

  def shrink(conn, %{"warehouse_id" => warehouse_id}) do
    with {:ok, warehouse} <- Logistics.shrink_warehouse(conn.assigns.scope, warehouse_id) do
      render(conn, :show, warehouse: warehouse)
    end
  end

  # -- Transfer to Ship --

  defparams :transfer_to_ship do
    required(:ship_id, :string, format: :uuid)
    required(:good_id, :string, format: :uuid)
    required(:quantity, :integer, min: 1)
  end

  operation(:transfer_to_ship,
    summary: "Transfer cargo to ship",
    description: "Transfers cargo from a warehouse to a docked ship.",
    security: [%{"bearerAuth" => []}],
    parameters: [
      %OpenApiSpex.Parameter{
        name: "tradewinds-company-id",
        in: :header,
        required: true,
        schema: %OpenApiSpex.Schema{type: :string, format: :uuid},
        description: "Company ID"
      },
      warehouse_id: [in: :path, description: "Warehouse ID", type: :string]
    ],
    request_body: {"Transfer details", "application/json", TransferToShipRequest},
    responses: [
      no_content: "Cargo transferred successfully",
      unprocessable_entity: {"Validation error", "application/json", ChangesetResponse},
      unauthorized: {"Invalid or expired token", "application/json", ErrorResponse},
      not_found: {"Warehouse or ship not found", "application/json", ErrorResponse}
    ]
  )

  def transfer_to_ship(conn, params = %{"warehouse_id" => warehouse_id}) do
    with {:ok, valid} <- validate(:transfer_to_ship, params),
         {:ok, :transferred} <-
           Logistics.transfer_to_ship(
             conn.assigns.scope,
             warehouse_id,
             valid.ship_id,
             valid.good_id,
             valid.quantity
           ) do
      send_resp(conn, :no_content, "")
    end
  end
end
