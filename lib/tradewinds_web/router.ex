defmodule TradewindsWeb.Router do
  use TradewindsWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
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
    plug TradewindsWeb.Plugs.CompanyContext
  end

  scope "/admin", TradewindsWeb do
    pipe_through :browser

    live "/setup", AdminSetupLive, :index
  end

  scope "/api/v1", TradewindsWeb do
    pipe_through :api

    get "/health", HealthController, :show
  end

  scope "/api/v1", TradewindsWeb do
    pipe_through [:api, :auth]
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
