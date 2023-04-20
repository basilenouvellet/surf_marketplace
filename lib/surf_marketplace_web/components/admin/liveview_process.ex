defmodule SurfMarketplaceWeb.Components.Admin.LiveviewProcess do
  use SurfMarketplaceWeb, :live_component

  def render(assigns) do
    ~H"""
    <div id={@id} class="p-4 space-y-4 text-sm text-neutral-500 bg-white rounded-md shadow-md">
      <div class="flex flex-wrap gap-3 justify-between items-baseline">
        <div class="flex flex-wrap gap-3 items-baseline">
          <%!-- PID button --%>
          <.pid_button id={@id} pid={@liveview.pid} />

          <%!-- Current page --%>
          <.current_page
            path={@liveview.assigns[:analytics_data][:current_path]}
            page_title={@liveview.assigns[:page_title]}
          />
        </div>

        <div class="flex flex-wrap gap-2 items-center">
          <%!-- Kill button --%>
          <.kill_button myself={@myself} />

          <%!-- RAM --%>
          <.ram memory={@liveview.memory} />
        </div>
      </div>

      <div class="flex flex-wrap gap-4 [&>*]:min-w-[min(100%,40ch)]">
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

        <%!-- Events --%>
        <.details class="flex-1">
          <:summary>Events</:summary>

          <div class="max-h-[20rem] mt-4 pb-2 px-4 overflow-y-auto">
            <ul id="events" class="flex flex-col gap-2">
              <li
                :for={event <- @events}
                class="flex flex-wrap items-baseline gap-4 p-2 text-sm text-neutral-700 bg-neutral-200/25 border border-neutral-300 rounded-md shadow"
              >
                <span class="text-xs tabular-nums text-neutral-500"><%= event.created_at %></span>
                <span class="font-semibold"><%= event.name %></span>
                <span class="text-neutral-600"><%= inspect(event.params) %></span>
              </li>

              <p :if={@events == []} class="mx-auto mt-2 text-xs text-neutral-400">no events yet</p>
            </ul>
          </div>
        </.details>
      </div>

      <.admin_message_modal id={@id} myself={@myself} string_pid={inspect(@liveview.pid)} />
    </div>
    """
  end

  ### Components

  attr :id, :string, required: true
  attr :pid, :any, required: true

  def pid_button(assigns) do
    ~H"""
    <button
      class="tabular-nums hover:bg-neutral-100 rounded p-1 transition-colors duration-75"
      phx-click={show_modal("admin-flash-message-modal-#{@id}")}
    >
      <%= inspect(@pid) %>
    </button>
    """
  end

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

  attr :myself, :any, required: true

  def kill_button(assigns) do
    ~H"""
    <button
      class="text-neutral-400/80 hover:text-neutral-400 hover:bg-neutral-100 rounded py-1 px-2 transition-colors duration-75"
      phx-click={JS.push("kill_liveview", target: @myself)}
    >
      <.icon name="hero-trash-mini" class="w-4 h-4 mb-0.5" />
    </button>
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
      "p-4 rounded-md border border-transparent [&[open]]:bg-neutral-50/50 [&[open]]:border-neutral-200/50",
      "transition-colors duration-75",
      @class
    ]}>
      <summary class={[
        "-m-4 p-2 font-medium rounded-t-md select-none cursor-pointer focus:outline-none",
        "hover:bg-neutral-100",
        "[details[open]>&]:bg-neutral-100",
        "[details:not([open])>&]:rounded-b-md",
        "transition-colors duration-75"
      ]}>
        <%= render_slot(@summary) %>
      </summary>

      <div class="pt-3 overflow-x-auto">
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
    <div class="mt-4 mb-2">
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
          <%= inspect(@data) %>
      <% end %>
    </span>
    """
  end

  attr :id, :string, required: true
  attr :myself, :any, required: true
  attr :string_pid, :string, required: true

  def admin_message_modal(assigns) do
    ~H"""
    <.modal id={"admin-flash-message-modal-#{@id}"}>
      <form
        id={"admin-flash-message-form-#{@id}"}
        class="max-w-sm mx-auto flex flex-col items-stretch space-y-6"
        phx-submit={
          JS.push("send_admin_flash_message", target: @myself)
          |> hide_modal("admin-flash-message-modal-#{@id}")
        }
      >
        <p class="text-zinc-800 font-bold">Send a flash message to user <%= @string_pid %></p>
        <textarea
          id={"admin-flash-message-input-#{@id}"}
          name="message"
          class="rounded-md"
          rows="4"
          required
        />
        <.button>Send</.button>
      </form>
    </.modal>
    """
  end

  ### Server

  def handle_event("send_admin_flash_message", %{"message" => msg}, socket) do
    send(socket.assigns.liveview.pid, {:admin_flash, :admin, msg})
    {:noreply, socket}
  end

  def handle_event("kill_liveview", _, socket) do
    Process.exit(socket.assigns.liveview.pid, :kill)
    {:noreply, socket}
  end
end
