alias Hawk.Repo
alias Hawk.Locations.Location
alias Hawk.Restaurants.Restaurant

Repo.delete_all(Restaurant)
Repo.delete_all(Location)

seeds = [
  %{
    name: "Earth",
    access_type: :bi,
    children: [
      %{
        name: "Europe",
        access_type: :bi,
        children: [
          %{
            name: "Poland",
            access_type: :single,
            children: [
              %{
                name: "Warsaw",
                access_type: :node,
                restaurants: ["Pierogi Palace", "Vistula View"]
              },
              %{
                name: "Krakow",
                access_type: :node,
                restaurants: ["Dragon's Den"]
              }
            ]
          },
          %{
            name: "Germany",
            access_type: :single,
            children: [
              %{name: "Berlin", access_type: :node, restaurants: ["Bratwurst Baron"]}
            ]
          }
        ]
      },
      %{
        name: "North America",
        access_type: :bi,
        children: [
          %{
            name: "USA",
            access_type: :bi,
            children: [
              %{
                name: "California",
                access_type: :single,
                children: [
                  %{name: "San Francisco", access_type: :node, restaurants: ["Sourdough Star"]},
                  %{name: "Los Angeles", access_type: :node, restaurants: ["Hollywood Hotdog"]}
                ]
              }
            ]
          },
          %{
            name: "Canada",
            access_type: :bi,
            children: [
              %{name: "Toronto", access_type: :node, restaurants: ["Maple Munchies"]}
            ]
          }
        ]
      }
    ]
  }
]

defmodule Seeder do
  alias Hawk.Repo
  alias Hawk.Locations.Location
  alias Hawk.Restaurants.Restaurant

  def insert_nodes(nodes, parent_id \\ nil) do
    Enum.each(nodes, fn node ->
      location =
        %Location{}
        |> Location.changeset(%{
          name: node.name,
          access_type: node.access_type,
          parent_id: parent_id
        })
        |> Repo.insert!()

      if Map.has_key?(node, :restaurants) do
        Enum.each(node.restaurants, fn res_name ->
          %Restaurant{}
          |> Restaurant.changeset(%{name: res_name, location_id: location.id})
          |> Repo.insert!()
        end)
      end

      if Map.has_key?(node, :children) do
        insert_nodes(node.children, location.id)
      end
    end)
  end
end

Seeder.insert_nodes(seeds)

IO.puts(
  "Successfully seeded #{Repo.aggregate(Location, :count, :id)} locations and #{Repo.aggregate(Restaurant, :count, :id)} restaurants."
)
