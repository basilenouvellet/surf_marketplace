defmodule SurfMarketplace.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      SurfMarketplaceWeb.Telemetry,
      # Start the Ecto repository
      SurfMarketplace.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: SurfMarketplace.PubSub},
      # Start Finch
      {Finch, name: SurfMarketplace.Finch},
      # Start the Endpoint (http/https)
      SurfMarketplaceWeb.Endpoint
      # Start a worker by calling: SurfMarketplace.Worker.start_link(arg)
      # {SurfMarketplace.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: SurfMarketplace.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    SurfMarketplaceWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
