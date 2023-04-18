defmodule SurfMarketplaceWeb.Admin.AnalyticsLive do
  use SurfMarketplaceWeb, :live_view

  def render(assigns) do
    ~H"""
    hey there ADMIN
    """
  end

  def mount(_params, _session, socket) do
    {:ok, socket, layout: false}
  end
end
