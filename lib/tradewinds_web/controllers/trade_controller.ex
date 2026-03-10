defmodule TradewindsWeb.TradeController do
  use TradewindsWeb, :controller
  use OpenApiSpex.ControllerSpecs
  use Goal

  alias Tradewinds.Trade
  alias TradewindsWeb.Schemas.{
    QuoteRequest,
    QuoteResponse,
    ExecuteQuoteRequest,
    ExecuteTradeRequest,
    TradeExecutionResponse,
    TraderPositionsResponse,
    ErrorResponse
  }

  action_fallback TradewindsWeb.FallbackController

  # -- Trader Positions --

  defparams :trader_positions do
    required(:port_id, :string, format: :uuid)
  end

  operation(:trader_positions,
    summary: "List trader positions",
    description: "Returns a list of goods a trader is buying or selling at a port.",
    parameters: [
      port_id: [in: :query, description: "Port ID", type: :string]
    ],
    responses: [
      ok: {"List of trader positions", "application/json", TraderPositionsResponse}
    ]
  )

  def trader_positions(conn, params) do
    with {:ok, valid} <- validate(:trader_positions, params) do
      positions = Trade.list_trader_positions(valid.port_id)
      render(conn, :trader_positions, positions: positions)
    end
  end

  # -- Quote --

  defparams :quote do
    required(:port_id, :string, format: :uuid)
    required(:good_id, :string, format: :uuid)
    required(:action, :string, included_in: ["buy", "sell"])
    required(:quantity, :integer, min: 1)
  end

  operation(:quote,
    summary: "Get a trade quote",
    description: "Generates a signed quote for a trade.",
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
    request_body: {"Quote request details", "application/json", QuoteRequest},
    responses: [
      ok: {"Quote generated successfully", "application/json", QuoteResponse},
      not_found: {"Market not found", "application/json", ErrorResponse},
      bad_request: {"Validation error", "application/json", ErrorResponse}
    ]
  )

  def quote(conn, params) do
    with {:ok, valid} <- validate(:quote, params) do
      action_atom = String.to_existing_atom(valid.action)

      case Trade.generate_quote(
             conn.assigns.scope,
             valid.port_id,
             valid.good_id,
             action_atom,
             valid.quantity
           ) do
        {:ok, token, quote_data} ->
          render(conn, :quote, token: token, quote_data: quote_data)

        {:error, reason} ->
          conn
          |> put_status(:bad_request)
          |> json(%{error: "bad_request", message: "Failed to generate quote: #{reason}"})
      end
    end
  end

  # -- Execute Quote --

  operation(:execute_quote,
    summary: "Execute a signed quote",
    description: "Executes a trade based on a previously generated quote token.",
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
    request_body: {"Execution details", "application/json", ExecuteQuoteRequest},
    responses: [
      ok: {"Trade executed successfully", "application/json", TradeExecutionResponse},
      unauthorized: {"Invalid token or ownership", "application/json", ErrorResponse},
      bad_request: {"Execution failed", "application/json", ErrorResponse}
    ]
  )

  def execute_quote(conn, %{"token" => token, "destinations" => dests}) when is_list(dests) do
    # Convert string keys to atoms for destinations
    formatted_dests =
      Enum.map(dests, fn d ->
        %{
          type: String.to_existing_atom(d["type"]),
          id: d["id"],
          quantity: d["quantity"]
        }
      end)

    case Trade.execute_quote(conn.assigns.scope, token, formatted_dests) do
      {:ok, trade_data} ->
        render(conn, :execute, trade_data: trade_data)

      {:error, reason} ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: "bad_request", message: "Failed to execute quote: #{reason}"})
    end
  end

  def execute_quote(conn, _params) do
    conn
    |> put_status(:bad_request)
    |> json(%{error: "bad_request", message: "Invalid payload format"})
  end

  # -- Execute Immediate --

  defparams :execute_immediate do
    required(:port_id, :string, format: :uuid)
    required(:good_id, :string, format: :uuid)
    required(:action, :string, included_in: ["buy", "sell"])
    required(:destinations, {:array, :map})
  end

  operation(:execute,
    summary: "Execute an immediate trade",
    description: "Executes a trade directly without a quote.",
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
    request_body: {"Trade details", "application/json", ExecuteTradeRequest},
    responses: [
      ok: {"Trade executed successfully", "application/json", TradeExecutionResponse},
      bad_request: {"Execution failed", "application/json", ErrorResponse}
    ]
  )

  def execute(conn, params) do
    with {:ok, valid} <- validate(:execute_immediate, params) do
      action_atom = String.to_existing_atom(valid.action)

      formatted_dests =
        Enum.map(valid.destinations, fn d ->
          # Ensure atom keys for the trade context
          %{
            type: String.to_existing_atom(d["type"] || d.type),
            id: d["id"] || d.id,
            quantity: d["quantity"] || d.quantity
          }
        end)

      case Trade.execute_immediate(
             conn.assigns.scope,
             valid.port_id,
             valid.good_id,
             action_atom,
             formatted_dests
           ) do
        {:ok, trade_data} ->
          render(conn, :execute, trade_data: trade_data)

        {:error, reason} ->
          conn
          |> put_status(:bad_request)
          |> json(%{error: "bad_request", message: "Failed to execute trade: #{reason}"})
      end
    end
  end
end
