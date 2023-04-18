defmodule SurfMarketplace.Admin.Analytics do
  def list_liveviews do
    list_liveviews_pids()
    # can't get our own state
    |> Enum.reject(&(&1 == self()))
    |> Enum.map(fn pid -> {pid, :sys.get_state(pid)} end)
    # don't observe liveviews related to /admin routes
    |> Enum.reject(fn {_pid, state} ->
      state
      |> get_in_socket(:view)
      |> is_child_view?([SurfMarketplaceWeb.Admin, Phoenix.LiveDashboard])
    end)
    |> Enum.reduce(%{}, fn {pid, state}, acc ->
      root_pid = get_in_socket(state, :root_pid)
      parent_pid = get_in_socket(state, :parent_pid)

      # NOTE: Don't observe child liveviews,
      #       only add their memory footprint to the one of the root_pid (= mother liveview).
      case Map.get(acc, root_pid) do
        nil when parent_pid == nil ->
          Map.put(acc, root_pid, %{
            pid: root_pid,
            assigns: get_socket_assigns(state),
            memory: get_memory(root_pid)
          })

        nil when parent_pid != nil ->
          Map.put(acc, root_pid, %{
            pid: root_pid,
            assigns: nil,
            memory: get_memory(pid)
          })

        _root_pid_stats when parent_pid == nil ->
          Map.update!(acc, root_pid, fn stats ->
            stats
            |> Map.update!(:memory, &(&1 + get_memory(pid)))
            |> Map.put(:assigns, get_socket_assigns(state))
          end)

        _root_pid_stats when parent_pid != nil ->
          Map.update!(acc, root_pid, fn stats ->
            stats
            |> Map.update!(:memory, &(&1 + get_memory(pid)))
          end)
      end
    end)
    |> Map.values()
  end

  def list_liveviews_pids do
    Process.list()
    |> Enum.map(
      &case Process.info(&1, [:dictionary]) do
        [{_, infos} | _] ->
          case Keyword.get(infos, :"$initial_call") do
            {Phoenix.LiveView.Channel, _, _} -> &1
            _ -> nil
          end

        _ ->
          nil
      end
    )
    |> Enum.reject(&is_nil/1)
  end

  ### Helpers

  defp is_child_view?(view, parent_views) do
    view = Atom.to_string(view)

    parent_views
    |> Enum.map(&Atom.to_string/1)
    |> Enum.any?(&String.starts_with?(view, &1))
  end

  defp get_in_socket(state, key) do
    get_in(state, [:socket, Access.key(key)])
  end

  defp get_socket_assigns(state) do
    state |> get_in_socket(:assigns) |> Map.drop([:__changed__])
  end

  defp get_memory(pid) do
    Process.info(pid, [:memory])[:memory]
  end
end
