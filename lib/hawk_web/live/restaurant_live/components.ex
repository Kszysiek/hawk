defmodule HawkWeb.RestaurantLive.Components do
  use Phoenix.Component
  alias HawkWeb.CoreComponents

  attr :tree, :list, required: true
  attr :selected_id, :any, default: nil

  def sidebar(assigns) do
    ~H"""
    <div class="w-1/3 bg-white border-r border-gray-200 overflow-y-auto p-4">
      <h2 class="text-xl font-bold mb-4 text-gray-800">Locations</h2>
      <div class="space-y-2">
        <.tree_node :for={node <- @tree} node={node} selected_id={@selected_id} />
      </div>
    </div>
    """
  end

  attr :node, :map, required: true
  attr :selected_id, :any, required: true

  def tree_node(assigns) do
    ~H"""
    <div>
      <div
        phx-click="select_location"
        phx-value-id={@node.id}
        class={[
          "cursor-pointer px-3 py-2 rounded-md text-sm font-medium transition flex items-center justify-between",
          @selected_id == @node.id && "bg-indigo-50 text-indigo-700",
          @selected_id != @node.id && "text-gray-700 hover:bg-gray-100"
        ]}
      >
        <span>{@node.name}</span>
        <span class="text-xs text-gray-400 font-normal ml-2">{@node.access_type}</span>
      </div>

      <div :if={@node.children != []} class="ml-4 border-l border-gray-200 pl-2 mt-1 space-y-1">
        <.tree_node :for={child <- @node.children} node={child} selected_id={@selected_id} />
      </div>
    </div>
    """
  end

  attr :selected_location, :map, default: nil
  attr :restaurants, :list, default: []

  def content_pane(assigns) do
    ~H"""
    <div class="flex-1 p-8 overflow-y-auto">
      <%= if @selected_location do %>
        <div class="mb-6">
          <h1 class="text-3xl font-bold text-gray-900">{@selected_location.name}</h1>
          <div class="mt-2 inline-flex items-center px-3 py-1 rounded-full text-sm font-medium bg-blue-100 text-blue-800">
            Access Type: {@selected_location.access_type}
          </div>
          <p class="mt-2 text-gray-600 text-sm">ID: {@selected_location.id}</p>
        </div>

        <div class="bg-white shadow rounded-lg overflow-hidden">
          <div class="px-6 py-4 border-b border-gray-200 bg-gray-50">
            <h3 class="text-lg font-medium text-gray-900">Accessible Restaurants</h3>
          </div>

          <ul role="list" class="divide-y divide-gray-200">
            <%= if @restaurants == [] do %>
              <li class="px-6 py-4 text-gray-500 italic">No accessible restaurants found.</li>
            <% else %>
              <li :for={r <- @restaurants} class="px-6 py-4 hover:bg-gray-50 transition">
                <div class="flex items-center justify-between">
                  <p class="text-sm font-medium text-indigo-600 truncate">{r.name}</p>
                  <div class="text-sm text-gray-500">
                    from {r.location_id}
                  </div>
                </div>
              </li>
            <% end %>
          </ul>
        </div>
      <% else %>
        <div class="flex flex-col items-center justify-center h-full text-gray-400">
          <CoreComponents.icon name="hero-map" class="w-16 h-16 mb-4" />
          <p class="text-lg">Select a location to view accessible restaurants</p>
        </div>
      <% end %>
    </div>
    """
  end
end
