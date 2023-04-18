defmodule SurfMarketplaceWeb.HomeLive do
  use SurfMarketplaceWeb, :live_view

  def render(assigns) do
    ~H"""
    hey there
    """
  end

  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end
