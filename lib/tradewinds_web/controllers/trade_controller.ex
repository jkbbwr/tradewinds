defmodule TradewindsWeb.TradeController do
  use TradewindsWeb, :controller
  use OpenApiSpex.ControllerSpecs
  use Goal

  alias Tradewinds.Trade

  alias TradewindsWeb.Schemas.{
    QuoteRequest,
    QuoteResponse,
    BatchQuoteRequest,
    BatchQuoteResponse,
    ExecuteQuoteRequest,
    BatchExecuteQuoteRequest,
    BatchExecuteQuoteResponse,
    ExecuteTradeRequest,
    TradeExecutionResponse,
    TraderPositionsResponse,
    TradersResponse,
    ErrorResponse
  }

  action_fallback TradewindsWeb.FallbackController

  # -- Traders --

  defparams :traders do
    optional(:after, :string)
    optional(:before, :string)
    optional(:limit, :integer, min: 1, max: 100)
  end

  operation(:traders,
    operation_id: "traders",
    tags: ["Trade"],
    summary: "List traders",
    description: "Returns a list of NPC traders.",
    parameters: [
      after: [in: :query, description: "Cursor for next page", type: :string],
      before: [in: :query, description: "Cursor for previous page", type: :string],
      limit: [in: :query, description: "Number of items per page", type: :integer]
    ],
    responses: [
      ok: {"List of traders", "application/json", TradersResponse}
    ]
  )

  def traders(conn, params) do
    with {:ok, valid} <- validate(:traders, params) do
      page = Trade.list_traders(valid)
      render(conn, :traders, page: page)
    end
  end

  # -- Trader Positions --

  defparams :trader_positions do
    optional(:port_id, :string, format: :uuid)
    optional(:after, :string)
    optional(:before, :string)
    optional(:limit, :integer, min: 1, max: 100)
  end

  operation(:trader_positions,
    operation_id: "traderPositions",
    tags: ["Trade"],
    summary: "List trader positions",
    description:
      "Returns a list of goods a trader is buying or selling optionally filtered by port..",
    parameters: [
      port_id: [in: :query, description: "Port ID", type: :string, required: false],
      after: [in: :query, description: "Cursor for next page", type: :string],
      before: [in: :query, description: "Cursor for previous page", type: :string],
      limit: [in: :query, description: "Number of items per page", type: :integer]
    ],
    responses: [
      ok: {"List of trader positions", "application/json", TraderPositionsResponse}
    ]
  )

  def trader_positions(conn, params) do
    with {:ok, valid} <- validate(:trader_positions, params) do
      port_id = Map.get(valid, :port_id)
      page = Trade.list_trader_positions(port_id, valid)
      render(conn, :trader_positions, page: page)
    end
  end

  # -- Quote --

  defparams :quote do
    required(:port_id, :string, format: :uuid)
    required(:good_id, :string, format: :uuid)
    required(:action, :enum, values: [:buy, :sell])
    required(:quantity, :integer, min: 1)
  end

  operation(:quote,
    operation_id: "quote",
    tags: ["Trade"],
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
    with {:ok, valid} <- validate(:quote, params),
         {:ok, token, quote_data} <-
           Trade.generate_quote(
             conn.assigns.scope,
             valid.port_id,
             valid.good_id,
             valid.action,
             valid.quantity
           ) do
      render(conn, :quote, token: token, quote_data: quote_data)
    end
  end

  # -- Batch Quote --

  defparams :batch_quote do
    required :requests, {:array, :map} do
      required(:port_id, :string, format: :uuid)
      required(:good_id, :string, format: :uuid)
      required(:action, :enum, values: ["buy", "sell"])
      required(:quantity, :integer, min: 1)
    end
  end

  operation(:batch_quote,
    operation_id: "batchQuote",
    tags: ["Trade"],
    summary: "Get multiple trade quotes",
    description: "Generates signed quotes for multiple trades at once.",
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
    request_body: {"Batch quote request details", "application/json", BatchQuoteRequest},
    responses: [
      ok: {"Batch quotes generated successfully", "application/json", BatchQuoteResponse},
      bad_request: {"Validation error", "application/json", ErrorResponse}
    ]
  )

  def batch_quote(conn, params) do
    with {:ok, valid} <- validate(:batch_quote, params) do
      results = Enum.map(valid.requests, &process_batch_quote(conn, &1))
      render(conn, :batch_quote, results: results)
    end
  end

  defp process_batch_quote(conn, req) do
    case Trade.generate_quote(
           conn.assigns.scope,
           req.port_id,
           req.good_id,
           req.action,
           req.quantity
         ) do
      {:ok, token, quote_data} ->
        %{status: "success", token: token, quote_data: quote_data}

      {:error, reason} ->
        %{status: "error", message: "Failed to generate quote: #{inspect(reason)}"}
    end
  end

  # -- Execute Quote --

  defparams :execute_quote do
    required(:token, :string)

    required :destinations, {:array, :map} do
      required(:type, :enum, values: ["ship", "warehouse"])
      required(:id, :string, format: :uuid)
      required(:quantity, :integer, min: 1)
    end
  end

  operation(:execute_quote,
    operation_id: "executeQuote",
    tags: ["Trade"],
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

  def execute_quote(conn, params) do
    with {:ok, valid} <- validate(:execute_quote, params),
         {:ok, trade_data} <-
           Trade.execute_quote(conn.assigns.scope, valid.token, valid.destinations) do
      render(conn, :execute, trade_data: trade_data)
    end
  end

  # -- Batch Execute Quote --

  defparams :batch_execute_quote do
    required :requests, {:array, :map} do
      required(:token, :string)

      required :destinations, {:array, :map} do
        required(:type, :enum, values: [:ship, :warehouse])
        required(:id, :string, format: :uuid)
        required(:quantity, :integer, min: 1)
      end
    end
  end

  operation(:batch_execute_quote,
    operation_id: "batchExecuteQuote",
    tags: ["Trade"],
    summary: "Execute multiple signed quotes",
    description: "Executes multiple trades based on previously generated quote tokens.",
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
    request_body: {"Batch execution details", "application/json", BatchExecuteQuoteRequest},
    responses: [
      ok: {"Trades executed successfully", "application/json", BatchExecuteQuoteResponse},
      bad_request: {"Execution failed", "application/json", ErrorResponse}
    ]
  )

  def batch_execute_quote(conn, params) do
    with {:ok, valid} <- validate(:batch_execute_quote, params) do
      results = Enum.map(valid.requests, &process_batch_execute(conn, &1))
      render(conn, :batch_execute_quote, results: results)
    end
  end

  defp process_batch_execute(conn, req) do
    case Trade.execute_quote(conn.assigns.scope, req.token, req.destinations) do
      {:ok, trade_data} ->
        %{status: "success", token: req.token, trade_data: trade_data}

      {:error, reason} ->
        %{
          status: "error",
          token: req.token,
          message: "Failed to execute quote: #{inspect(reason)}"
        }
    end
  end

  # -- Execute Immediate --

  defparams :execute_immediate do
    required(:port_id, :string, format: :uuid)
    required(:good_id, :string, format: :uuid)
    required(:action, :enum, values: ["buy", "sell"])

    required :destinations, {:array, :map} do
      required(:type, :enum, values: ["ship", "warehouse"])
      required(:id, :string, format: :uuid)
      required(:quantity, :integer, min: 1)
    end
  end

  operation(:execute,
    operation_id: "execute",
    tags: ["Trade"],
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
    with {:ok, valid} <- validate(:execute_immediate, params),
         {:ok, trade_data} <-
           Trade.execute_immediate(
             conn.assigns.scope,
             valid.port_id,
             valid.good_id,
             valid.action,
             valid.destinations
           ) do
      render(conn, :execute, trade_data: trade_data)
    end
  end
end
