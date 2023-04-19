defmodule SurfMarketplaceWeb.Router do
  use SurfMarketplaceWeb, :router

  import Phoenix.LiveDashboard.Router

  alias SurfMarketplaceWeb.Hooks

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {SurfMarketplaceWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :admin do
    plug :admin_basic_auth
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", SurfMarketplaceWeb do
    pipe_through :browser

    live_session :default, on_mount: Hooks.Analytics do
      live "/", HomeLive
    end
  end

  scope "/admin", SurfMarketplaceWeb do
    pipe_through :browser
    if Mix.env() == :prod, do: pipe_through(:admin)

    live "/analytics", Admin.AnalyticsLive
    live_dashboard "/dashboard", metrics: SurfMarketplaceWeb.Telemetry
  end

  # Enable Swoosh mailbox preview in development
  if Application.compile_env(:surf_marketplace, :dev_routes) do
    scope "/dev" do
      pipe_through :browser

      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ### Plugs

  defp admin_basic_auth(conn, _opts) do
    username = Application.fetch_env!(:surf_marketplace, :admin_basic_auth)[:username]
    password = Application.fetch_env!(:surf_marketplace, :admin_basic_auth)[:password]

    Plug.BasicAuth.basic_auth(conn, username: username, password: password)
  end
end
