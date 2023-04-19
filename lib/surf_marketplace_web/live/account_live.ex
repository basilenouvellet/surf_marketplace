defmodule SurfMarketplaceWeb.AccountLive do
  use SurfMarketplaceWeb, :live_view

  def render(assigns) do
    ~H"""
    <h1 class="mx-auto font-semibold text-lg">
      <%= case @live_action do %>
        <% :register -> %>
          Register
        <% :log_in -> %>
          Log in
      <% end %>
    </h1>
    """
  end

  ### Server

  def handle_params(_params, _url, socket) do
    {:noreply, assign_page_title(socket)}
  end

  ### Helpers

  def assign_page_title(%{assigns: %{live_action: :register}} = socket) do
    assign(socket, page_title: "Register")
  end

  def assign_page_title(%{assigns: %{live_action: :log_in}} = socket) do
    assign(socket, page_title: "Log in")
  end
end
