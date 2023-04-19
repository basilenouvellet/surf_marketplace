defmodule SurfMarketplaceWeb.Components.Admin.LiveviewProcess do
  use SurfMarketplaceWeb, :live_component

  def render(assigns) do
    ~H"""
    <div id={@id} class="p-4 space-y-4 text-sm text-neutral-500 bg-white rounded-md shadow-md">
      <div class="flex flex-wrap gap-3 justify-between items-baseline">
        <div class="flex flex-wrap gap-3 items-baseline">
          <%!-- PID --%>
          <button
            class="tabular-nums hover:bg-neutral-100 rounded p-1 transition-colors duration-75"
            phx-click={show_modal("admin-flash-message-modal-#{@id}")}
          >
            <%= inspect(@liveview.pid) %>
          </button>

          <%!-- Current page --%>
          <.current_page
            path={@liveview.assigns[:analytics_data][:current_path]}
            page_title={@liveview.assigns[:page_title]}
          />
        </div>

        <%!-- RAM --%>
        <.ram memory={@liveview.memory} />
      </div>

      <div class="flex flex-wrap gap-4 [&>*]:min-w-[min(100%,30ch)]">
        <%!-- Assigns --%>
        <.details class="flex-1">
          <:summary>Assigns</:summary>

          <.pretty_print data={Map.drop(@liveview.assigns, [:analytics_data])} />
        </.details>

        <%!-- Analytics Data --%>
        <.details class="flex-1">
          <:summary>Analytics</:summary>

          <.pretty_print data={@liveview.assigns[:analytics_data]} />
        </.details>
      </div>

      <.admin_message_modal id={@id} myself={@myself} />
    </div>
    """
  end

  ### Components

  attr :path, :string, required: true
  attr :page_title, :string, required: true

  def current_page(assigns) do
    ~H"""
    <p class="flex items-baseline gap-3 text-blue-700 bg-blue-100 rounded-full py-0.5 px-2">
      <span :if={@page_title}><%= @page_title %></span>
      <span class="font-semibold"><%= @path || "no path found" %></span>
    </p>
    """
  end

  attr :memory, :integer, required: true

  def ram(assigns) do
    ~H"""
    <p class={[
      "tabular-nums rounded-full py-0.5 px-2 transition-colors",
      cond do
        @memory in 0..50_000 -> "text-green-700 bg-green-100"
        @memory in 50_000..300_000 -> "text-orange-700 bg-orange-100"
        true -> "text-red-700 bg-red-100"
      end
    ]}>
      <%= Size.humanize!(@memory) %>
    </p>
    """
  end

  attr :class, :string, default: nil
  slot :summary, required: true
  slot :inner_block, required: true

  def details(assigns) do
    ~H"""
    <details class={[
      "p-2 rounded-md border border-transparent [&[open]]:bg-neutral-50/50 [&[open]]:border-neutral-200/50",
      "transition-colors duration-75",
      @class
    ]}>
      <summary class={[
        "-m-2 p-2 font-medium rounded-t-md select-none cursor-pointer focus:outline-none",
        "hover:bg-neutral-100",
        "[details[open]>&]:bg-neutral-100",
        "[details:not([open])>&]:rounded-b-md",
        "[details[open]>&]:mb-2",
        "transition-colors duration-75"
      ]}>
        <%= render_slot(@summary) %>
      </summary>

      <div class="pb-2 overflow-x-auto">
        <%= render_slot(@inner_block) %>
      </div>
    </details>
    """
  end

  attr :data, :any, required: true

  def pretty_print(%{data: data} = assigns) when is_struct(data) do
    pretty_print(%{assigns | data: inspect(data)})
  end

  def pretty_print(%{data: data} = assigns) when is_map(data) and data != %{} do
    ~H"""
    <div>
      <div :for={{key, value} <- @data} class="flex flex-nowrap">
        <span class="mr-2"><%= key %>:</span>
        <.pretty_print data={value} />
      </div>
    </div>
    """
  end

  def pretty_print(%{data: data} = assigns) when is_list(data) and data != [] do
    ~H"""
    <div class="space-y-4">
      <div :for={elem <- @data} class="flex flex-nowrap">
        <.pretty_print data={elem} />
      </div>
    </div>
    """
  end

  def pretty_print(assigns) do
    ~H"""
    <span class="pr-12 font-medium text-neutral-600 whitespace-nowrap">
      <%= cond do %>
        <% @data == nil -> %>
          nil
        <% @data == [] -> %>
          []
        <% @data == %{} -> %>
          %{}
        <% true -> %>
          <%= @data %>
      <% end %>
    </span>
    """
  end

  attr :id, :string, required: true
  attr :myself, :any, required: true

  def admin_message_modal(assigns) do
    ~H"""
    <.modal id={"admin-flash-message-modal-#{@id}"}>
      <form
        id={"admin-flash-message-form-#{@id}"}
        class="flex flex-col items-start space-y-6"
        phx-submit={
          JS.push("send_admin_flash_message", target: @myself)
          |> hide_modal("admin-flash-message-modal-#{@id}")
        }
      >
        <textarea id={"admin-flash-message-input-#{@id}"} name="message" />
        <.button>Send</.button>
      </form>
    </.modal>
    """
  end

  ### Server

  def mount(socket) do
    {:ok, socket}
  end

  def handle_event("send_admin_flash_message", %{"message" => msg}, socket) do
    send_admin_flash(socket.assigns.liveview.pid, msg)
    {:noreply, socket}
  end

  ### Helpers

  def send_admin_flash(_pid, ""), do: nil

  def send_admin_flash(pid, message) when is_binary(message) do
    # TODO: special "admin" level message with special UI in flash group
    send(pid, {:admin_flash, :info, message})
  end
end
