defmodule SurfMarketplaceWeb.Hooks.Analytics do
  import Phoenix.LiveView
  import Phoenix.Component
  import SurfMarketplaceWeb.Helpers

  def on_mount(:default, _params, _session, socket) do
    socket =
      socket
      |> assign_analytics_data()
      |> attach_hook(:set_current_path, :handle_params, &set_current_path/3)

    {:cont, socket}
  end

  ### Helpers

  defp assign_analytics_data(socket) do
    assign(socket,
      analytics_data: %{
        # NOTE: Will be set in handle_params hook.
        current_path: nil,
        window_width: get_connect_params(socket)["window_width"],
        window_height: get_connect_params(socket)["window_height"],
        screen_width: get_connect_params(socket)["screen_width"],
        screen_height: get_connect_params(socket)["screen_height"],
        language: get_connect_params(socket)["language"]
      }
    )
  end

  defp set_current_path(_params, url, socket) do
    current_path = url_to_path(url)
    socket = update(socket, :analytics_data, &%{&1 | current_path: current_path})
    {:cont, socket}
  end
end
