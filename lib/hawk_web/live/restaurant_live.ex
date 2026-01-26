defmodule HawkWeb.RestaurantLive do
  use HawkWeb, :live_view

  alias Hawk.Locations
  alias Hawk.Restaurants
  alias HawkWeb.RestaurantLive.Components

  def mount(_params, _session, socket) do
    locations = Locations.list_locations()
    tree = build_tree(locations)

    {:ok,
     socket
     |> assign(:tree, tree)
     |> assign(:selected_location, nil)
     |> assign(:restaurants, [])}
  end

  def handle_event("select_location", %{"id" => id}, socket) do
    location = Locations.get_location!(id)
    restaurants = Restaurants.list_accessible_restaurants(location)

    {:noreply,
     socket
     |> assign(:selected_location, location)
     |> assign(:restaurants, restaurants)}
  end

  defp build_tree(locations) do
    grouped = Enum.group_by(locations, & &1.parent_id)

    build_children(grouped, nil)
  end

  defp build_children(grouped, parent_id) do
    grouped
    |> Map.get(parent_id, [])
    |> Enum.map(fn loc ->
      Map.put(loc, :children, build_children(grouped, loc.id))
    end)
    |> Enum.sort_by(& &1.name)
  end

  def render(assigns) do
    ~H"""
    <div class="flex h-screen bg-gray-50">
      <Components.sidebar tree={@tree} selected_id={@selected_location && @selected_location.id} />
      <Components.content_pane selected_location={@selected_location} restaurants={@restaurants} />
    </div>
    """
  end
end
