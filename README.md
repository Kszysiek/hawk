# Hawk

- Run `mix setup` to install and setup dependencies
- Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

You can visit [`localhost:4000/restaurants`](http://localhost:4000/restaurants) to check the basic visualization for the restaurants

## Searching methods

- :node
  - Allows to find all restaurants in selected location and it's siblings
- :single
  - recursively searches downwards, fetches only restaurants that are direct child of the selected location
- :bi
  - searches upwards respecting parent access type
    - bi - looks further upwards
    - node - fetches siblings as well
    - single - looks only down the tree

### Other options I considered

- Materialized paths
  - Should be easier to query
  - Harder to maintain since changing one location name would result in updating all descendants as well
