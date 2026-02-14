defmodule Hawk.Restaurants do
  import Ecto.Query
  alias Hawk.Repo
  alias Hawk.Restaurants.Restaurant
  alias Hawk.Locations.Location

  def list_accessible_restaurants(%Location{} = location) do
    list_accessible_restaurants(location.id, location.access_type, location.parent_id)
  end

  def list_accessible_restaurants(location_id) when is_binary(location_id) do
    location = Repo.get!(Location, location_id)
    list_accessible_restaurants(location.id, location.access_type, location.parent_id)
  end

  defp list_accessible_restaurants(location_id, :single, _parent_id) do
    descendants = descendants_cte(location_id)

    query =
      from r in Restaurant, join: d in "descendants", on: r.location_id == d.id, select: r

    query
    |> recursive_ctes(true)
    |> with_cte("descendants", as: ^descendants)
    |> Repo.all()
  end

  defp list_accessible_restaurants(_location_id, :node, parent_id) do
    base =
      from l in Location,
        where: l.parent_id == ^parent_id,
        select: %{id: l.id}

    recursive =
      from l in Location,
        join: t in "node_tree",
        on: l.parent_id == t.id,
        select: %{id: l.id}

    node_tree = union(base, ^recursive)

    from(r in Restaurant, join: t in "node_tree", on: r.location_id == t.id)
    |> recursive_ctes(true)
    |> with_cte("node_tree", as: ^node_tree)
    |> Repo.all()
  end

  defp list_accessible_restaurants(location_id, :bi, _parent_id) do
    ancestors = ancestors_cte(location_id)

    seeds =
      from a in "ancestors",
        left_join: s in Location,
        on: a.access_type == "node" and s.parent_id == a.parent_id,
        select: %{id: coalesce(s.id, a.id)}

    recursive_tree =
      from l in Location,
        join: t in "tree",
        on: l.parent_id == t.id,
        select: %{id: l.id}

    tree = union(seeds, ^recursive_tree)

    from(r in Restaurant, join: t in "tree", on: r.location_id == t.id, select: r)
    |> recursive_ctes(true)
    |> with_cte("ancestors", as: ^ancestors)
    |> with_cte("tree", as: ^tree)
    |> Repo.all()
  end

  defp ancestors_cte(start_id) do
    base =
      from l in Location,
        where: l.id == ^start_id,
        select: %{id: l.id, parent_id: l.parent_id, access_type: type(l.access_type, :string)}

    recursive =
      from l in Location,
        join: c in "ancestors",
        on: l.id == c.parent_id,
        where: c.access_type == "bi",
        select: %{id: l.id, parent_id: l.parent_id, access_type: type(l.access_type, :string)}

    union_all(base, ^recursive)
  end

  defp descendants_cte(root_id) do
    base =
      from l in Location,
        where: l.id == ^root_id,
        select: %{id: l.id}

    recursive =
      from l in Location, join: t in "descendants", on: l.parent_id == t.id, select: %{id: l.id}

    union_all(base, ^recursive)
  end
end
