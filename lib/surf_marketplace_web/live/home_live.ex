defmodule SurfMarketplaceWeb.HomeLive do
  use SurfMarketplaceWeb, :live_view

  def render(assigns) do
    ~H"""
    <form id="price_form" phx-change="price_changed">
      <label for="price_input" class="font-semibold mr-2">Price:</label>
      <input id="price_input" type="number" name="price" />
    </form>
    """
  end

  def mount(_params, _session, socket) do
    socket =
      assign(socket,
        page_title: "Home",
        price: nil
      )

    {:ok, socket}
  end

  def handle_event("price_changed", %{"price" => price} = _args, socket) do
    {:noreply, assign(socket, price: price)}
  end
end
