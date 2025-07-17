alias Tradewinds.Repo
alias Tradewinds.World
alias Tradewinds.Trading
alias Tradewinds.World.{Country, Port, Item}
alias Tradewinds.Trading.Trader
alias Tradewinds.Shipyards
alias Tradewinds.Shipyard.Shipyard
import Ecto.Query

IO.puts "Seeding Europe from europe.json..."

json_path = Path.join(__DIR__, "europe.json")
json_data = File.read!(json_path) |> Jason.decode!()

Enum.each(json_data, fn country_data ->
  IO.puts "  Creating country: #{country_data["name"]}"

  {:ok, country} =
    World.create_country(country_data["name"], country_data["description"])

  Enum.each(country_data["ports"], fn port_data ->
    IO.puts "    Creating port: #{port_data["name"]}"

    {:ok, port} =
      World.create_port(port_data["name"], port_data["shortcode"], country.id)

    IO.puts "      Creating trader for #{port.name}"
    Trading.create_trader(port)

    if Map.get(port_data, "shipyard", false) do
      IO.puts "      Creating shipyard for #{port.name}"
      Shipyards.create_shipyard(port.id)
    end
  end)
end)

IO.puts "Seeding routes from europe_routes.json..."

routes_json_path = Path.join(__DIR__, "europe_routes.json")
routes_json_data = File.read!(routes_json_path) |> Jason.decode!()

ports = World.list_ports() |> Enum.map(fn port -> {port.shortcode, port.id} end) |> Map.new()

Enum.each(routes_json_data, fn route_data ->
  from_id = ports[route_data["from"]]
  to_id = ports[route_data["to"]]

  if from_id && to_id do
    case World.create_route(from_id, to_id, route_data["distance"]) do
      {:ok, _} ->
        :ok
      {:error, changeset} ->
        IO.inspect(changeset)
        IO.puts "Error creating route"
    end
  else
    IO.puts "Could not find ports for route #{route_data["from"]} -> #{route_data["to"]}"
  end
end)

IO.puts "Seeding trader plans from europe_trader_plan.json..."

trader_plan_json_path = Path.join(__DIR__, "europe_trader_plan.json")
trader_plan_json_data = File.read!(trader_plan_json_path) |> Jason.decode!()

traders = Repo.all(Trader) |> Enum.map(fn trader -> {trader.port_id, trader.id} end) |> Map.new()
items = Repo.all(Item) |> Enum.map(fn item -> {item.name, item.id} end) |> Map.new()
ports_by_name = World.list_ports() |> Enum.map(fn port -> {port.name, port.id} end) |> Map.new()

Enum.each(trader_plan_json_data, fn plan_data ->
  port_id = ports_by_name[plan_data["port_name"]]
  trader_id = traders[port_id]
  item_id = items[plan_data["item_name"]]

  case Trading.create_trader_plan(
         trader_id,
         item_id,
         plan_data["average_acquisition_cost"],
         plan_data["ideal_stock_level"],
         plan_data["target_profit_margin"],
         plan_data["max_buy_sell_spread"],
         plan_data["price_elasticity"],
         plan_data["liquidity_factor"],
         plan_data["consumption_rate"],
         plan_data["reversion_rate"],
         plan_data["regional_cost"]
       ) do
    {:ok, _} ->
      :ok
    {:error, changeset} ->
      IO.inspect(changeset)
      IO.puts "Error creating trader plan"
  end
end)


IO.puts "Finished seeding Europe."
