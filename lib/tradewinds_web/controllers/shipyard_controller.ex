defmodule TradewindsWeb.ShipyardController do
  use TradewindsWeb, :controller
  use Goal
  use OpenApiSpex.ControllerSpecs

  alias Tradewinds.Shipyards

  alias TradewindsWeb.Schemas.{
    ShipyardResponse,
    InventoryResponse,
    PurchaseShipRequest,
    SellShipRequest,
    SellShipResponse,
    ShipResponse,
    ErrorResponse,
    ChangesetResponse
  }

  action_fallback TradewindsWeb.FallbackController

  # -- Shipyard for Port --

  operation(:shipyard_for_port,
    operation_id: "shipyardForPort",
    tags: ["Shipyards"],
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
    operation_id: "inventory",
    tags: ["Shipyards"],
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
    operation_id: "purchase",
    tags: ["Shipyards"],
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

  # -- Sell Ship --

  defparams :sell do
    required(:ship_id, :string, format: :uuid)
  end

  operation(:sell,
    operation_id: "sellShip",
    tags: ["Shipyards"],
    summary: "Sell a ship",
    description: "Sells a ship back to the shipyard at a variable loss.",
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
    request_body: {"Sell details", "application/json", SellShipRequest},
    responses: [
      ok: {"Ship sold successfully", "application/json", SellShipResponse},
      unprocessable_entity: {"Validation error", "application/json", ChangesetResponse},
      unauthorized: {"Invalid or expired token", "application/json", ErrorResponse},
      forbidden: {"Unauthorized or ship not at shipyard", "application/json", ErrorResponse},
      not_found: {"Shipyard or ship not found", "application/json", ErrorResponse}
    ]
  )

  def sell(conn, params = %{"shipyard_id" => shipyard_id}) do
    with {:ok, valid} <- validate(:sell, params),
         {:ok, result} <-
           Shipyards.sell_ship(conn.assigns.scope, shipyard_id, valid.ship_id) do
      render(conn, :sell, price: result.price)
    end
  end

  # -- Sell Quote --

  defparams :sell_quote do
    optional(:ship_id, :string, format: :uuid)
    optional(:ship_type_id, :string, format: :uuid)
  end

  operation(:sell_quote,
    operation_id: "sellQuote",
    tags: ["Shipyards"],
    summary: "Get a sell quote for a ship",
    description: "Returns the estimated buy-back price for a ship if sold to this shipyard.",
    parameters: [
      shipyard_id: [in: :path, description: "Shipyard ID", type: :string],
      ship_id: [in: :query, description: "Ship ID", type: :string, required: false],
      ship_type_id: [in: :query, description: "Ship Type ID", type: :string, required: false]
    ],
    responses: [
      ok: {"Sell quote", "application/json", SellShipResponse},
      not_found: {"Shipyard, ship, or ship type not found", "application/json", ErrorResponse}
    ]
  )

  def sell_quote(conn, params = %{"shipyard_id" => shipyard_id}) do
    with {:ok, valid} <- validate(:sell_quote, params),
         {:ok, ship_type_id} <- resolve_ship_type_id(valid),
         {:ok, price} <- Shipyards.calculate_sell_price(ship_type_id, shipyard_id) do
      render(conn, :sell, price: price)
    end
  end

  defp resolve_ship_type_id(%{ship_type_id: ship_type_id}), do: {:ok, ship_type_id}

  defp resolve_ship_type_id(%{ship_id: ship_id}) do
    case Tradewinds.Fleet.fetch_ship(ship_id) do
      {:ok, ship} -> {:ok, ship.ship_type_id}
      {:error, reason} -> {:error, reason}
    end
  end

  defp resolve_ship_type_id(_), do: {:error, :missing_parameters}
end
