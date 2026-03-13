defmodule Tradewinds.EventsTest do
  use Tradewinds.DataCase
  alias Tradewinds.Events
  alias Phoenix.PubSub

  @pubsub Tradewinds.PubSub

  describe "broadcast_ship_transit_started/2" do
    test "broadcasts ship_set_sail with company_id to world topic" do
      company = insert(:company)
      route = insert(:route)
      ship = insert(:ship, company: company, name: "The Flying Dutchman", route: route, port: nil, status: :traveling)

      PubSub.subscribe(@pubsub, "events:world:all")

      Events.broadcast_ship_transit_started(company.id, ship)

      assert_receive {:message, %{type: "ship_set_sail", data: data}}
      assert data.ship_id == ship.id
      assert data.name == "The Flying Dutchman"
      assert data.company_id == company.id
    end
  end

  describe "broadcast_ship_docked/2" do
    test "broadcasts ship_docked_world with company_id to world topic" do
      company = insert(:company)
      port = insert(:port)
      ship = insert(:ship, company: company, name: "The Black Pearl", port: port, route: nil, status: :docked)

      PubSub.subscribe(@pubsub, "events:world:all")

      Events.broadcast_ship_docked(company.id, ship)

      assert_receive {:message, %{type: "ship_docked_world", data: data}}
      assert data.ship_id == ship.id
      assert data.name == "The Black Pearl"
      assert data.company_id == company.id
    end
  end
end
