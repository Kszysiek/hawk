# Hawk

- Run `mix setup` to install and setup dependencies
- Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

You can visit [`localhost:4000/restaurants`](http://localhost:4000/restaurants) to check the basic visualization for the restaurants

## Searching methods

- :node
  - allows to search for only the selected location
- :single
  - recursively searches downwards, fetches only restaurants that are direct child of the selected location
- :bi
  - finds all the restaurants in the database, finds the root of the tree and recursively looks for the restaurants
  - with current implementation it assumes there is only one root
