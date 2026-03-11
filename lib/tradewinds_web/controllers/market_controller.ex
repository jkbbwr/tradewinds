defmodule TradewindsWeb.MarketController do
  use TradewindsWeb, :controller
  use Goal
  use OpenApiSpex.ControllerSpecs

  alias Tradewinds.Market

  alias TradewindsWeb.Schemas.{
    OrdersResponse,
    OrderResponse,
    BlendedPriceResponse,
    CreateOrderRequest,
    FillOrderRequest,
    ErrorResponse,
    ChangesetResponse
  }

  action_fallback TradewindsWeb.FallbackController

  # -- Orders --

  defparams :orders do
    required(:port_id, :string, format: :uuid)
    required(:good_id, :string, format: :uuid)
    required(:side, :string, included_in: ["buy", "sell"])
    optional(:after, :string)
    optional(:before, :string)
    optional(:limit, :integer, min: 1, max: 100)
  end

  operation(:orders,
    operation_id: "orders",
    tags: ["Market"],
    summary: "List open market orders",
    description: "Returns a list of open orders for a specific port, good, and side.",
    parameters: [
      port_id: [in: :query, description: "Port ID", type: :string],
      good_id: [in: :query, description: "Good ID", type: :string],
      side: [in: :query, description: "Order side (buy or sell)", type: :string],
      after: [in: :query, description: "Cursor for next page", type: :string],
      before: [in: :query, description: "Cursor for previous page", type: :string],
      limit: [in: :query, description: "Number of items per page", type: :integer]
    ],
    responses: [
      ok: {"List of orders", "application/json", OrdersResponse},
      unprocessable_entity: {"Validation error", "application/json", ChangesetResponse}
    ]
  )

  def orders(conn, params) do
    with {:ok, valid} <- validate(:orders, params) do
      side_atom = String.to_existing_atom(valid.side)
      page = Market.list_orders(valid.port_id, valid.good_id, side_atom, valid)
      render(conn, :index, page: page)
    end
  end

  # -- Blended Price --

  defparams :blended_price do
    required(:port_id, :string, format: :uuid)
    required(:good_id, :string, format: :uuid)
    required(:side, :string, included_in: ["buy", "sell"])
    required(:quantity, :integer, min: 1)
  end

  operation(:blended_price,
    operation_id: "blendedPrice",
    tags: ["Market"],
    summary: "Calculate blended price",
    description: "Calculates the blended price for filling a specific quantity of an order.",
    parameters: [
      port_id: [in: :query, description: "Port ID", type: :string],
      good_id: [in: :query, description: "Good ID", type: :string],
      side: [in: :query, description: "Order side (buy or sell)", type: :string],
      quantity: [in: :query, description: "Quantity to fill", type: :integer]
    ],
    responses: [
      ok: {"Blended price", "application/json", BlendedPriceResponse},
      unprocessable_entity: {"Validation error", "application/json", ChangesetResponse},
      bad_request: {"No liquidity available", "application/json", ErrorResponse}
    ]
  )

  def blended_price(conn, params) do
    with {:ok, valid} <- validate(:blended_price, params) do
      side_atom = String.to_existing_atom(valid.side)

      case Market.calculate_blended_price(valid.port_id, valid.good_id, side_atom, valid.quantity) do
        {:ok, price} ->
          render(conn, :blended_price, blended_price: price)

        {:error, :no_liquidity} ->
          conn
          |> put_status(:bad_request)
          |> json(%{error: "no_liquidity", message: "Not enough liquidity to fulfill quantity."})
      end
    end
  end

  # -- Create Order --

  defparams :create_order do
    required(:port_id, :string, format: :uuid)
    required(:good_id, :string, format: :uuid)
    required(:side, :string, included_in: ["buy", "sell"])
    required(:price, :integer, min: 1)
    required(:total, :integer, min: 1)
  end

  operation(:create_order,
    operation_id: "createOrder",
    tags: ["Market"],
    summary: "Create a market order",
    description: "Posts a new order to the market.",
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
    request_body: {"Order details", "application/json", CreateOrderRequest},
    responses: [
      created: {"Order created successfully", "application/json", OrderResponse},
      unprocessable_entity: {"Validation error", "application/json", ChangesetResponse},
      unauthorized: {"Invalid or expired token", "application/json", ErrorResponse},
      forbidden: {"Insufficient funds or reputation", "application/json", ErrorResponse}
    ]
  )

  def create_order(conn, params) do
    with {:ok, valid} <- validate(:create_order, params),
         side_atom = String.to_existing_atom(valid.side),
         {:ok, order} <-
           Market.post_order(
             conn.assigns.scope,
             valid.port_id,
             valid.good_id,
             side_atom,
             valid.price,
             valid.total
           ) do
      conn
      |> put_status(:created)
      |> render(:show, order: order)
    end
  end

  # -- Fill Order --

  defparams :fill_order do
    required(:quantity, :integer, min: 1)
  end

  operation(:fill_order,
    operation_id: "fillOrder",
    tags: ["Market"],
    summary: "Fill an order",
    description: "Fills a specified quantity of an open order.",
    security: [%{"bearerAuth" => []}],
    parameters: [
      %OpenApiSpex.Parameter{
        name: "tradewinds-company-id",
        in: :header,
        required: true,
        schema: %OpenApiSpex.Schema{type: :string, format: :uuid},
        description: "Company ID"
      },
      order_id: [in: :path, description: "Order ID", type: :string]
    ],
    request_body: {"Fill details", "application/json", FillOrderRequest},
    responses: [
      ok: {"Order filled successfully", "application/json", OrderResponse},
      unprocessable_entity: {"Validation error", "application/json", ChangesetResponse},
      unauthorized: {"Invalid or expired token", "application/json", ErrorResponse},
      not_found: {"Order not found", "application/json", ErrorResponse},
      bad_request: {"Trade voided or invalid quantity", "application/json", ErrorResponse}
    ]
  )

  def fill_order(conn, params = %{"order_id" => order_id}) do
    with {:ok, valid} <- validate(:fill_order, params) do
      case Market.fill_order(conn.assigns.scope, order_id, valid.quantity) do
        {:ok, order} ->
          render(conn, :show, order: order)

        {:error, {:trade_voided, reason, _offender_id}} ->
          conn
          |> put_status(:bad_request)
          |> json(%{error: "trade_voided", message: "Trade was voided due to #{reason}."})

        {:error, reason} ->
          conn
          |> put_status(:bad_request)
          |> json(%{error: "bad_request", message: "Trade failed: #{reason}"})
      end
    end
  end

  # -- Delete Order --

  operation(:delete_order,
    operation_id: "deleteOrder",
    tags: ["Market"],
    summary: "Cancel an order",
    description: "Cancels an open order.",
    security: [%{"bearerAuth" => []}],
    parameters: [
      %OpenApiSpex.Parameter{
        name: "tradewinds-company-id",
        in: :header,
        required: true,
        schema: %OpenApiSpex.Schema{type: :string, format: :uuid},
        description: "Company ID"
      },
      order_id: [in: :path, description: "Order ID", type: :string]
    ],
    responses: [
      no_content: "Order cancelled successfully",
      unauthorized: {"Invalid or expired token", "application/json", ErrorResponse},
      not_found: {"Order not found", "application/json", ErrorResponse}
    ]
  )

  def delete_order(conn, %{"order_id" => order_id}) do
    with {:ok, _order} <- Market.cancel_order(conn.assigns.scope, order_id) do
      send_resp(conn, :no_content, "")
    end
  end
end
