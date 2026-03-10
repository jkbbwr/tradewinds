defmodule TradewindsWeb.WorldController do
  use TradewindsWeb, :controller
  use Goal
  use OpenApiSpex.ControllerSpecs

  alias Tradewinds.World
  alias TradewindsWeb.Schemas.{
    PortsResponse,
    PortResponse,
    GoodsResponse,
    GoodResponse,
    ShipTypesResponse,
    ShipTypeResponse,
    RoutesResponse,
    RouteResponse,
    ErrorResponse
  }

  action_fallback TradewindsWeb.FallbackController

  # -- Ports --

  defparams :ports do
    optional(:after, :string)
    optional(:before, :string)
    optional(:limit, :integer, min: 1, max: 100)
  end

  operation(:ports,
    summary: "List ports",
    description: "Returns a list of all ports in the world.",
    parameters: [
      after: [in: :query, description: "Cursor for next page", type: :string],
      before: [in: :query, description: "Cursor for previous page", type: :string],
      limit: [in: :query, description: "Number of items per page", type: :integer]
    ],
    responses: [
      ok: {"List of ports", "application/json", PortsResponse}
    ]
  )

  def ports(conn, params) do
    with {:ok, valid} <- validate(:ports, params) do
      opts = Map.take(valid, [:after, :before, :limit]) |> Map.to_list()
      page = World.list_ports(opts)
      render(conn, :ports, page: page)
    end
  end

  operation(:port,
    summary: "Get port details",
    description: "Returns the details of a specific port.",
    parameters: [
      id: [in: :path, description: "Port ID", type: :string]
    ],
    responses: [
      ok: {"Port details", "application/json", PortResponse},
      not_found: {"Port not found", "application/json", ErrorResponse}
    ]
  )

  def port(conn, %{"id" => id}) do
    with {:ok, port} <- World.fetch_port(id) do
      render(conn, :port, port: port)
    end
  end

  # -- Goods --

  operation(:goods,
    summary: "List goods",
    description: "Returns a list of all tradeable goods.",
    responses: [
      ok: {"List of goods", "application/json", GoodsResponse}
    ]
  )

  def goods(conn, _params) do
    goods = World.list_goods()
    render(conn, :goods, goods: goods)
  end

  operation(:good,
    summary: "Get good details",
    description: "Returns the details of a specific good.",
    parameters: [
      id: [in: :path, description: "Good ID", type: :string]
    ],
    responses: [
      ok: {"Good details", "application/json", GoodResponse},
      not_found: {"Good not found", "application/json", ErrorResponse}
    ]
  )

  def good(conn, %{"id" => id}) do
    with {:ok, good} <- World.fetch_good(id) do
      render(conn, :good, good: good)
    end
  end

  # -- Ship Types --

  operation(:ship_types,
    summary: "List ship types",
    description: "Returns a list of all available ship types.",
    responses: [
      ok: {"List of ship types", "application/json", ShipTypesResponse}
    ]
  )

  def ship_types(conn, _params) do
    ship_types = World.list_ship_types()
    render(conn, :ship_types, ship_types: ship_types)
  end

  operation(:ship_type,
    summary: "Get ship type details",
    description: "Returns the details of a specific ship type.",
    parameters: [
      id: [in: :path, description: "Ship Type ID", type: :string]
    ],
    responses: [
      ok: {"Ship type details", "application/json", ShipTypeResponse},
      not_found: {"Ship type not found", "application/json", ErrorResponse}
    ]
  )

  def ship_type(conn, %{"id" => id}) do
    with {:ok, ship_type} <- World.fetch_ship_type(id) do
      render(conn, :ship_type, ship_type: ship_type)
    end
  end

  # -- Routes --

  defparams :routes do
    optional(:after, :string)
    optional(:before, :string)
    optional(:limit, :integer, min: 1, max: 100)
  end

  operation(:routes,
    summary: "List routes",
    description: "Returns a list of all routes in the world.",
    parameters: [
      after: [in: :query, description: "Cursor for next page", type: :string],
      before: [in: :query, description: "Cursor for previous page", type: :string],
      limit: [in: :query, description: "Number of items per page", type: :integer]
    ],
    responses: [
      ok: {"List of routes", "application/json", RoutesResponse}
    ]
  )

  def routes(conn, params) do
    with {:ok, valid} <- validate(:routes, params) do
      opts = Map.take(valid, [:after, :before, :limit]) |> Map.to_list()
      page = World.list_routes(opts)
      render(conn, :routes, page: page)
    end
  end

  operation(:route,
    summary: "Get route details",
    description: "Returns the details of a specific route by ID.",
    parameters: [
      id: [in: :path, description: "Route ID", type: :string]
    ],
    responses: [
      ok: {"Route details", "application/json", RouteResponse},
      not_found: {"Route not found", "application/json", ErrorResponse}
    ]
  )

  def route(conn, %{"id" => id}) do
    with {:ok, route} <- World.fetch_route_by_id(id) do
      render(conn, :route, route: route)
    end
  end
end
