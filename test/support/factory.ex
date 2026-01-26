defmodule Hawk.Factory do
  use ExMachina.Ecto, repo: Hawk.Repo

  def location_factory do
    %Hawk.Locations.Location{
      name: sequence(:name, &"Location #{&1}"),
      access_type: :single,
      parent: nil
    }
  end

  def restaurant_factory do
    %Hawk.Restaurants.Restaurant{
      name: sequence(:name, &"Restaurant #{&1}"),
      location: build(:location)
    }
  end
end
