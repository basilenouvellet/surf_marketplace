defmodule SurfMarketplaceWeb.HomeLive do
  use SurfMarketplaceWeb, :live_view

  def render(%{live_action: :index} = assigns) do
    ~H"""
    <div class="max-w-lg flex items-stretch gap-10">
      <.big_button patch={~p"/buy"}>Buy</.big_button>
      <.big_button patch={~p"/sell"}>Sell</.big_button>
    </div>
    """
  end

  def render(%{live_action: :buy} = assigns) do
    ~H"""
    <h1 class="mx-auto font-semibold text-2xl">Buy</h1>
    """
  end

  def render(%{live_action: :sell} = assigns) do
    ~H"""
    <h1 class="mb-4 mx-auto font-semibold text-2xl">Sell</h1>

    <form id="price_form" phx-change="price_changed">
      <label for="price_input" class="font-semibold mr-2">Price:</label>
      <input id="price_input" type="number" name="price" class="rounded-md" />
    </form>
    """
  end

  ### Components

  attr :rest, :global, include: ~w"patch"
  slot :inner_block, required: true

  def big_button(assigns) do
    ~H"""
    <.link
      class={[
        "flex flex-1 justify-center items-center py-10 px-4",
        "font-semibold text-xl text-neutral-50 bg-brand-600 rounded-lg"
      ]}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </.link>
    """
  end

  ### Server

  def mount(_params, _session, socket) do
    {:ok, assign(socket, price: nil)}
  end

  def handle_params(_params, _url, socket) do
    {:noreply, assign_page_title(socket)}
  end

  def handle_event("price_changed", %{"price" => price} = _args, socket) do
    {:noreply, assign(socket, price: price)}
  end

  ### Helpers

  defp assign_page_title(socket) when socket.assigns.live_action == :buy do
    assign(socket, page_title: "Buy")
  end

  defp assign_page_title(socket) when socket.assigns.live_action == :sell do
    assign(socket, page_title: "Sell")
  end

  defp assign_page_title(socket) do
    assign(socket, page_title: "Home")
  end
end
