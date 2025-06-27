defmodule Tradewinds.LogisticsTest do
  use Tradewinds.DataCase, async: true

  import Tradewinds.Factory

  alias Tradewinds.Logistics

  describe "set_sail/2" do
    test "sets a ship to sail between two ports" do
      port1 = insert(:port)
      port2 = insert(:port)
      route = insert(:route, from: port1, to: port2, distance: 100)
      ship = insert(:ship, port: port1, speed: 10)

      now = DateTime.utc_now() |> DateTime.truncate(:second)
      {:ok, updated_ship} = Logistics.set_sail(ship, port2)

      assert updated_ship.state == :at_sea
      assert updated_ship.port_id == nil
      assert updated_ship.route_id == route.id
      assert updated_ship.arriving_at > now
    end

    test "returns an error if no route exists" do
      port1 = insert(:port)
      port2 = insert(:port)
      ship = insert(:ship, port: port1)

      assert Logistics.set_sail(ship, port2) == {:error, :route_not_found}
    end
  end
end
