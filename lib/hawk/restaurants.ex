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

  defp list_accessible_restaurants(location_id, :node, _parent_id) do
    query =
      from r in Restaurant,
        join: l in Location,
        on: r.location_id == l.id,
        where: l.id == ^location_id

    Repo.all(query)
  end

  defp list_accessible_restaurants(location_id, :bi, _parent_id) do
    ancestors = ancestors_cte(location_id)

    root_selector =
      from a in "ancestors",
        where: is_nil(a.parent_id),
        select: %{id: a.id}

    tree_recursion =
      from l in Location, join: t in "tree", on: l.parent_id == t.id, select: %{id: l.id}

    full_tree = union_all(root_selector, ^tree_recursion)

    query =
      from r in Restaurant, join: t in "tree", on: r.location_id == t.id, select: r

    query
    |> recursive_ctes(true)
    |> with_cte("ancestors", as: ^ancestors)
    |> with_cte("tree", as: ^full_tree)
    |> Repo.all()
  end

  defp ancestors_cte(start_id) do
    base =
      from l in Location,
        where: l.id == ^start_id,
        select: %{id: l.id, parent_id: l.parent_id}

    recursive =
      from l in Location,
        join: c in "ancestors",
        on: l.id == c.parent_id,
        select: %{id: l.id, parent_id: l.parent_id}

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
