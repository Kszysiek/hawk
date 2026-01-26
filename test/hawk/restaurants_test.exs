defmodule Hawk.RestaurantsTest do
  use Hawk.DataCase

  import Hawk.Factory
  alias Hawk.Restaurants

  @pierogi_restaurant_name "Pierogi"
  @dragon_restaurant_name "Dragon"
  @sourdough_restaurant_name "Sourdough"

  setup do
    # root
    earth = insert(:location, name: "Earth", access_type: :bi, parent: nil)

    # setup poland
    poland = insert(:location, name: "Poland", access_type: :single, parent: earth)
    warsaw = insert(:location, name: "Warsaw", access_type: :node, parent: poland)
    krakow = insert(:location, name: "Krakow", access_type: :node, parent: poland)

    insert(:restaurant, name: @pierogi_restaurant_name, location: warsaw)
    insert(:restaurant, name: @dragon_restaurant_name, location: krakow)

    # setup usa
    usa = insert(:location, name: "USA", access_type: :bi, parent: earth)
    california = insert(:location, name: "California", access_type: :single, parent: usa)
    sf = insert(:location, name: "SF", access_type: :node, parent: california)

    insert(:restaurant, name: @sourdough_restaurant_name, location: sf)

    %{
      earth: earth,
      poland: poland,
      warsaw: warsaw,
      krakow: krakow,
      usa: usa,
      california: california,
      sf: sf
    }
  end

  describe "list_accessible_restaurants/1" do
    test "type :single returns only direct children restaurants", %{poland: poland} do
      poland_restaurants = Restaurants.list_accessible_restaurants(poland)
      poland_restaurants_names = Enum.map(poland_restaurants, & &1.name)

      expected_names = [@pierogi_restaurant_name, @dragon_restaurant_name]

      assert length(poland_restaurants) == length(expected_names)
      assert Enum.all?(expected_names, &(&1 in poland_restaurants_names))
    end

    test "type :single returns deep descendants (recursive down)", %{
      california: california,
      sf: sf
    } do
      mission = insert(:location, name: "Mission", access_type: :node, parent: sf)
      burrito_restaurant = insert(:restaurant, name: "Burrito", location: mission)

      california_restaurants = Restaurants.list_accessible_restaurants(california)
      california_restaurants_names = Enum.map(california_restaurants, & &1.name)

      expected_names = [@sourdough_restaurant_name, burrito_restaurant.name]

      assert length(california_restaurants) == length(expected_names)
      assert Enum.all?(expected_names, &(&1 in california_restaurants_names))
    end

    test "type :node returns restaurants from only the current location", %{warsaw: warsaw} do
      warsaw_restaurants = Restaurants.list_accessible_restaurants(warsaw)
      warsaw_restaurants_names = Enum.map(warsaw_restaurants, & &1.name)

      expected_names = [@pierogi_restaurant_name]
      assert length(warsaw_restaurants) == length(expected_names)

      assert Enum.all?(expected_names, &(&1 in warsaw_restaurants_names))
    end

    test "type :bi returns all entires for root", %{earth: earth} do
      earth_restaurants = Restaurants.list_accessible_restaurants(earth)
      earth_restaurants_names = Enum.map(earth_restaurants, & &1.name)

      expected_names = [
        @pierogi_restaurant_name,
        @dragon_restaurant_name,
        @sourdough_restaurant_name
      ]

      assert length(earth_restaurants) == length(expected_names)
      assert Enum.all?(expected_names, &(&1 in earth_restaurants_names))
    end

    test "type :bi returns results from from root", %{poland: poland} do
      rzeszow = insert(:location, name: "Rzeszów", access_type: :bi, parent: poland)
      baranowka = insert(:location, name: "baranowka", access_type: :single, parent: rzeszow)
      baranowka_restaurant_1 = insert(:restaurant, name: "schabowy", location: baranowka)
      baranowka_restaurant_2 = insert(:restaurant, name: "ziemniaki", location: baranowka)

      bi_poland_restaurants = Restaurants.list_accessible_restaurants(rzeszow)
      bi_poland_restaurants_names = Enum.map(bi_poland_restaurants, & &1.name)

      expected_names = [
        baranowka_restaurant_1.name,
        baranowka_restaurant_2.name,
        @pierogi_restaurant_name,
        @dragon_restaurant_name,
        @sourdough_restaurant_name
      ]

      assert Enum.all?(
               expected_names,
               fn name -> name in bi_poland_restaurants_names end
             )

      assert length(bi_poland_restaurants_names) == length(expected_names)
    end
  end
end
