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
    <h1 class="mb-6 mx-auto font-semibold text-2xl">Sell</h1>

    <form id="price_form" phx-change="price_changed" class="flex flex-col gap-2">
      <!-- Prevent implicit submission of the form when hitting the Enter key -->
      <button type="submit" disabled style="display: none" aria-hidden="true" />

      <label for="price_input" class="font-semibold">Price</label>
      <div class="flex gap-4">
        <.small_button phx-click="decrement">-</.small_button>
        <input id="price_input" type="number" name="price" value={@price} class="rounded-md" />
        <.small_button phx-click="increment">+</.small_button>
      </div>
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

  attr :rest, :global
  slot :inner_block, required: true

  def small_button(assigns) do
    ~H"""
    <button
      type="button"
      class={[
        "flex justify-center items-center py-1 px-4",
        "font-semibold text-xl text-brand-600 bg-brand-600/25 rounded-lg"
      ]}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </button>
    """
  end

  ### Server

  def mount(_params, _session, socket) do
    {:ok, assign(socket, price: 0)}
  end

  def handle_params(_params, _url, socket) do
    {:noreply, assign_page_title(socket)}
  end

  def handle_event("price_changed", args, socket) do
    price =
      case Integer.parse(args["price"]) do
        {p, _} -> p
        _ -> 0
      end

    {:noreply, assign(socket, price: price)}
  end

  def handle_event("decrement", _args, socket) do
    {:noreply, update(socket, :price, &(&1 - 10))}
  end

  def handle_event("increment", _args, socket) do
    {:noreply, update(socket, :price, &(&1 + 10))}
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
