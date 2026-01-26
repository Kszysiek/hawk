defmodule Hawk.Locations.Location do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "locations" do
    field :name, :string
    field :access_type, Ecto.Enum, values: [:single, :bi, :node]

    belongs_to :parent, Hawk.Locations.Location
    has_many :children, Hawk.Locations.Location, foreign_key: :parent_id
    has_many :restaurants, Hawk.Restaurants.Restaurant

    timestamps(type: :utc_datetime)
  end

  def changeset(location, attrs) do
    location
    |> cast(attrs, [:name, :access_type, :parent_id])
    |> validate_required([:name, :access_type])
  end
end
