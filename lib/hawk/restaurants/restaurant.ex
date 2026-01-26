defmodule Hawk.Restaurants.Restaurant do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "restaurants" do
    field :name, :string
    belongs_to :location, Hawk.Locations.Location

    timestamps(type: :utc_datetime)
  end

  def changeset(restaurant, attrs) do
    restaurant
    |> cast(attrs, [:name, :location_id])
    |> validate_required([:name, :location_id])
  end
end
