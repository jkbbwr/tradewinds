defmodule TradewindsWeb.ShipyardController do
  use TradewindsWeb, :controller
  use Goal
  use OpenApiSpex.ControllerSpecs

  alias Tradewinds.Shipyards
  alias TradewindsWeb.Schemas.{
    ShipyardResponse,
    InventoryResponse,
    PurchaseShipRequest,
    ShipResponse,
    ErrorResponse,
    ChangesetResponse
  }

  action_fallback TradewindsWeb.FallbackController

  # -- Shipyard for Port --

  operation(:shipyard_for_port,
    summary: "Get shipyard for port",
    description: "Returns the shipyard located at a specific port.",
    parameters: [
      port_id: [in: :path, description: "Port ID", type: :string]
    ],
    responses: [
      ok: {"Shipyard details", "application/json", ShipyardResponse},
      not_found: {"Shipyard not found", "application/json", ErrorResponse}
    ]
  )

  def shipyard_for_port(conn, %{"port_id" => port_id}) do
    with {:ok, shipyard} <- Shipyards.fetch_shipyard_for_port(port_id) do
      render(conn, :show, shipyard: shipyard)
    end
  end

  # -- Shipyard Inventory --

  operation(:inventory,
    summary: "Get shipyard inventory",
    description: "Returns all unowned ships available for purchase at a shipyard.",
    parameters: [
      shipyard_id: [in: :path, description: "Shipyard ID", type: :string]
    ],
    responses: [
      ok: {"List of ships in inventory", "application/json", InventoryResponse},
      not_found: {"Shipyard not found", "application/json", ErrorResponse}
    ]
  )

  def inventory(conn, %{"shipyard_id" => shipyard_id}) do
    with {:ok, inventory} <- Shipyards.fetch_shipyard_inventory(shipyard_id) do
      render(conn, :inventory, inventory: inventory)
    end
  end

  # -- Purchase Ship --

  defparams :purchase do
    required(:ship_type_id, :string, format: :uuid)
  end

  operation(:purchase,
    summary: "Purchase a ship",
    description: "Purchases a ship from the shipyard inventory for the current company.",
    security: [%{"bearerAuth" => []}],
    parameters: [
      %OpenApiSpex.Parameter{
        name: "tradewinds-company-id",
        in: :header,
        required: true,
        schema: %OpenApiSpex.Schema{type: :string, format: :uuid},
        description: "Company ID"
      },
      shipyard_id: [in: :path, description: "Shipyard ID", type: :string]
    ],
    request_body: {"Purchase details", "application/json", PurchaseShipRequest},
    responses: [
      ok: {"Ship purchased successfully", "application/json", ShipResponse},
      unprocessable_entity: {"Validation error", "application/json", ChangesetResponse},
      unauthorized: {"Invalid or expired token", "application/json", ErrorResponse},
      forbidden: {"Insufficient funds or unauthorized", "application/json", ErrorResponse},
      not_found: {"Shipyard or inventory not found", "application/json", ErrorResponse}
    ]
  )

  def purchase(conn, params = %{"shipyard_id" => shipyard_id}) do
    with {:ok, valid} <- validate(:purchase, params),
         {:ok, ship} <-
           Shipyards.purchase_ship(conn.assigns.scope, shipyard_id, valid.ship_type_id) do
      conn
      |> put_status(:ok)
      |> put_view(TradewindsWeb.ShipJSON)
      |> render(:show, ship: ship)
    end
  end
end
