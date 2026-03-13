defmodule TradewindsWeb.Router do
  use TradewindsWeb, :router

  import Phoenix.LiveDashboard.Router

  defp admin_auth(conn, _opts) do
    # This fetch happens at runtime
    config = Application.get_env(:tradewinds, :admin_auth)
    username = config[:username]
    password = config[:password]

    # Use Plug's built-in basic_auth helper
    Plug.BasicAuth.basic_auth(conn, username: username, password: password)
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug TradewindsWeb.Plugs.IPBan
    plug TradewindsWeb.Plugs.RateLimiter
    plug OpenApiSpex.Plug.PutApiSpec, module: TradewindsWeb.ApiSpec
  end

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :put_root_layout, html: {TradewindsWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :auth do
    plug TradewindsWeb.Plugs.Auth
  end

  pipeline :company_context do
    plug TradewindsWeb.Plugs.CompanyContext
  end

  pipeline :strict_rate_limits do
    plug TradewindsWeb.Plugs.RateLimiter, limit: 10, scale: 60_000
  end

  scope "/admin", TradewindsWeb do
    pipe_through [:browser, :admin_auth]

    live_dashboard "/dashboard",
      metrics: TradewindsWeb.Telemetry,
      additional_pages: [
        oban: Oban.LiveDashboard
      ]
  end

  scope "/api" do
    pipe_through :api

    get "/openapi", OpenApiSpex.Plug.RenderSpec, []
    get "/swaggerui", OpenApiSpex.Plug.SwaggerUI, path: "/api/openapi"
  end

  scope "/api/v1/auth", TradewindsWeb do
    pipe_through [:api, :strict_rate_limits]

    post "/register", AuthController, :register
    post "/login", AuthController, :login
  end

  scope "/api/v1/auth", TradewindsWeb do
    pipe_through [:api, :strict_rate_limits, :auth]

    post "/revoke", AuthController, :revoke
  end

  scope "/api/v1", TradewindsWeb do
    pipe_through :api

    get "/health", HealthController, :show
  end

  scope "/api/v1", TradewindsWeb do
    pipe_through [:api, :auth]

    get "/me", AuthController, :me
    get "/me/companies", CompanyController, :companies

    post "/companies", CompanyController, :create_company
  end

  scope "/api/v1/company/", TradewindsWeb do
    pipe_through [:api, :auth, :company_context]

    get "/", CompanyController, :company
    get "/economy", CompanyController, :economy
    get "/ledger", CompanyController, :ledger
    get "/events", EventController, :company_events
  end

  scope "/api/v1/world", TradewindsWeb do
    pipe_through :api

    get "/ports", WorldController, :ports
    get "/ports/:id", WorldController, :port
    get "/ports/:port_id/shipyard", ShipyardController, :shipyard_for_port

    get "/goods", WorldController, :goods
    get "/goods/:id", WorldController, :good

    get "/ship-types", WorldController, :ship_types
    get "/ship-types/:id", WorldController, :ship_type

    get "/routes", WorldController, :routes
    get "/routes/:id", WorldController, :route

    get "/events", EventController, :world_events
  end

  scope "/api/v1/shipyards", TradewindsWeb do
    pipe_through :api

    get "/:shipyard_id/inventory", ShipyardController, :inventory
  end

  scope "/api/v1/ships", TradewindsWeb do
    pipe_through [:api, :auth, :company_context]

    get "/", ShipController, :ships
    get "/:ship_id", ShipController, :ship
    get "/:ship_id/inventory", ShipController, :inventory
    get "/:ship_id/transit-logs", ShipController, :transit_logs
    patch "/:ship_id", ShipController, :rename_ship
    post "/:ship_id/transit", ShipController, :transit
    post "/:ship_id/transfer-to-warehouse", ShipController, :transfer_to_warehouse
  end

  scope "/api/v1/warehouses", TradewindsWeb do
    pipe_through [:api, :auth, :company_context]

    get "/", WarehouseController, :warehouses
    post "/", WarehouseController, :create
    get "/:warehouse_id", WarehouseController, :warehouse
    get "/:warehouse_id/inventory", WarehouseController, :inventory
    post "/:warehouse_id/grow", WarehouseController, :grow
    post "/:warehouse_id/shrink", WarehouseController, :shrink
    post "/:warehouse_id/transfer-to-ship", WarehouseController, :transfer_to_ship
  end

  scope "/api/v1/shipyards", TradewindsWeb do
    pipe_through [:api, :auth, :company_context]

    post "/:shipyard_id/purchase", ShipyardController, :purchase
  end

  scope "/api/v1/trade", TradewindsWeb do
    pipe_through :api

    get "/traders", TradeController, :traders
    get "/trader-positions", TradeController, :trader_positions
  end

  scope "/api/v1/trade", TradewindsWeb do
    pipe_through [:api, :auth, :company_context]

    post "/quote", TradeController, :quote
    post "/quotes/batch", TradeController, :batch_quote
    post "/quotes/execute", TradeController, :execute_quote
    post "/quotes/execute/batch", TradeController, :batch_execute_quote
    post "/execute", TradeController, :execute
  end

  scope "/api/v1/market", TradewindsWeb do
    pipe_through :api

    get "/orders", MarketController, :orders
    get "/blended-price", MarketController, :blended_price
  end

  scope "/api/v1/market", TradewindsWeb do
    pipe_through [:api, :auth, :company_context]

    post "/orders", MarketController, :create_order
    post "/orders/:order_id/fill", MarketController, :fill_order
    delete "/orders/:order_id", MarketController, :delete_order
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:tradewinds, :dev_routes) do
    scope "/dev" do
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
