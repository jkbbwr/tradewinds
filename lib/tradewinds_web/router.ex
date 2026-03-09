defmodule TradewindsWeb.Router do
  use TradewindsWeb, :router

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

  pipeline :admin_auth do
    import Plug.BasicAuth
    plug :basic_auth, Application.compile_env(:tradewinds, :admin_auth)
  end

  scope "/admin", TradewindsWeb do
    pipe_through [:browser, :admin_auth]

    live "/setup", AdminSetupLive, :index
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

  scope "/api/v1", TradewindsWeb do
    pipe_through [:api, :auth, :company_context]

    get "/company", CompanyController, :company
    get "/company/economy", CompanyController, :economy
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

    get "/routes/:id", WorldController, :route
  end

  scope "/api/v1/shipyards", TradewindsWeb do
    pipe_through :api

    get "/:shipyard_id/inventory", ShipyardController, :inventory
  end

  scope "/api/v1/ships", TradewindsWeb do
    pipe_through [:api, :auth, :company_context]

    get "/", ShipController, :ships
    get "/:ship_id", ShipController, :ship
    patch "/:ship_id", ShipController, :rename_ship
    post "/:ship_id/transit", ShipController, :transit
    post "/:ship_id/transfer-to-warehouse", ShipController, :transfer_to_warehouse
  end

  scope "/api/v1/warehouses", TradewindsWeb do
    pipe_through [:api, :auth, :company_context]

    get "/", WarehouseController, :warehouses
    get "/:warehouse_id", WarehouseController, :warehouse
    post "/:warehouse_id/grow", WarehouseController, :grow
    post "/:warehouse_id/shrink", WarehouseController, :shrink
    post "/:warehouse_id/transfer-to-ship", WarehouseController, :transfer_to_ship
  end

  scope "/api/v1/shipyards", TradewindsWeb do
    pipe_through [:api, :auth, :company_context]

    post "/:shipyard_id/purchase", ShipyardController, :purchase
  end

  scope "/api/v1/trade", TradewindsWeb do
    pipe_through [:api, :auth, :company_context]

    post "/quote", TradeController, :quote
    post "/quotes/execute", TradeController, :execute_quote
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
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through [:fetch_session, :protect_from_forgery]

      live_dashboard "/dashboard",
        metrics: TradewindsWeb.Telemetry,
        additional_pages: [
          oban: Oban.LiveDashboard
        ]

      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
