defmodule Hawk.Locations do
  import Ecto.Query, warn: false
  alias Hawk.Repo
  alias Hawk.Locations.Location

  def list_locations do
    Repo.all(from l in Location, order_by: [asc: :name])
  end

  def get_location!(id), do: Repo.get!(Location, id)

  def list_locations_tree do
    Repo.all(from l in Location, order_by: [asc: :name])
  end
end
