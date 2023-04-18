defmodule SurfMarketplaceWeb.Admin.AnalyticsLive do
  use SurfMarketplaceWeb, :live_view

  alias SurfMarketplace.Admin.Analytics

  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-brand-600/90 text-neutral-900 p-6 flex flex-col gap-8">
      <div class="flex justify-between items-center flex-wrap gap-4">
        <h1 class="font-bold text-xl text-brand-900 uppercase">Analytics</h1>

        <p class="flex flex-wrap items-baseline gap-y-1 gap-x-4 py-1 px-4 bg-neutral-50/50 rounded-full tabular-nums">
          <span class="font-semibold"><%= length(@liveviews) %>&nbsp;connected</span>
          <span class="text-xs"><%= @last_refreshed_at || "..." %></span>
        </p>
      </div>

      <div class="flex flex-col gap-4">
        <.live_component
          :for={lv <- @liveviews}
          module={SurfMarketplaceWeb.Components.Admin.LiveviewProcess}
          id={"liveview-process-#{inspect lv.pid}"}
          liveview={lv}
        />
      </div>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    socket =
      assign(socket,
        page_title: "Analytics",
        liveviews: [],
        last_refreshed_at: nil
      )

    send(self(), :refresh)

    {:ok, socket, layout: false}
  end

  def handle_info(:refresh, socket) do
    socket =
      assign(socket,
        liveviews: Analytics.list_liveviews(),
        last_refreshed_at: utc_now()
      )

    schedule_refresh()

    {:noreply, socket}
  end

  ### Helpers

  @refresh_interval 500

  defp schedule_refresh do
    Process.send_after(self(), :refresh, @refresh_interval)
  end

  defp utc_now do
    DateTime.utc_now() |> DateTime.truncate(:second) |> DateTime.to_iso8601()
  end
end
