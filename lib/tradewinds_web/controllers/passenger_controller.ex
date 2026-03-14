defmodule TradewindsWeb.PassengerController do
  use TradewindsWeb, :controller
  use Goal
  use OpenApiSpex.ControllerSpecs

  alias Tradewinds.Passengers

  alias TradewindsWeb.Schemas.{
    PassengerResponse,
    PassengersResponse,
    BoardPassengerRequest,
    ErrorResponse
  }

  action_fallback TradewindsWeb.FallbackController

  # -- Index --

  defparams :index do
    optional(:after, :string)
    optional(:before, :string)
    optional(:limit, :integer, min: 1, max: 100)
    optional(:status, :string)
    optional(:port_id, :string, format: :uuid)
    optional(:ship_id, :string, format: :uuid)
  end

  operation(:index,
    operation_id: "listPassengers",
    tags: ["Passengers"],
    summary: "List all passengers",
    description: "Returns a paginated list of all currently available or boarded passengers.",
    parameters: [
      after: [in: :query, description: "Cursor for next page", type: :string],
      before: [in: :query, description: "Cursor for previous page", type: :string],
      limit: [in: :query, description: "Number of items per page", type: :integer],
      status: [in: :query, description: "Filter by status (available, boarded)", type: :string],
      port_id: [in: :query, description: "Filter by origin port ID", type: :string],
      ship_id: [in: :query, description: "Filter by ship ID", type: :string]
    ],
    responses: [
      ok: {"List of passengers", "application/json", PassengersResponse}
    ]
  )

  def index(conn, params) do
    with {:ok, valid} <- validate(:index, params) do
      page = Passengers.list_passengers(valid)
      render(conn, :index, page: page)
    end
  end

  # -- Show --

  operation(:show,
    operation_id: "getPassenger",
    tags: ["Passengers"],
    summary: "Get a passenger",
    description: "Returns a single passenger by ID.",
    parameters: [
      id: [in: :path, description: "Passenger ID", type: :string]
    ],
    responses: [
      ok: {"Passenger details", "application/json", PassengerResponse},
      not_found: {"Passenger not found", "application/json", ErrorResponse}
    ]
  )

  def show(conn, %{"id" => id}) do
    with {:ok, passenger} <- Passengers.fetch_passenger(id) do
      render(conn, :show, passenger: passenger)
    end
  end

  # -- Board --

  operation(:board,
    operation_id: "boardPassenger",
    tags: ["Passengers"],
    summary: "Board a passenger onto a ship",
    description: "Boards an available passenger group onto a docked ship at the same port.",
    security: [%{"bearerAuth" => []}],
    parameters: [
      %OpenApiSpex.Parameter{
        name: "tradewinds-company-id",
        in: :header,
        required: true,
        schema: %OpenApiSpex.Schema{type: :string, format: :uuid},
        description: "Company ID"
      },
      passenger_id: [in: :path, description: "Passenger ID", type: :string]
    ],
    request_body: {"Board request", "application/json", BoardPassengerRequest},
    responses: [
      ok: {"Boarded passenger details", "application/json", PassengerResponse},
      unprocessable_entity: {"Boarding failed", "application/json", ErrorResponse},
      unauthorized: {"Invalid or expired token", "application/json", ErrorResponse}
    ]
  )

  def board(conn, %{"passenger_id" => passenger_id, "ship_id" => ship_id}) do
    with {:ok, passenger} <- Passengers.board_passenger(conn.assigns.scope, ship_id, passenger_id) do
      render(conn, :show, passenger: passenger)
    end
  end
end
