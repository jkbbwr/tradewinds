defmodule Tradewinds.WorldTest do
  use Tradewinds.DataCase, async: true

  import Tradewinds.Factory

  alias Tradewinds.World

  describe "get_port_by_name/1" do
    test "returns a port by name" do
      port = insert(:port, name: "Test Port")

      {:ok, found_port} = World.get_port_by_name("Test Port")

      assert found_port.id == port.id
    end

    test "returns an error if port is not found" do
      assert World.get_port_by_name("Nonexistent Port") == {:error, :not_found}
    end
  end

  describe "get_port_by_shortcode/1" do
    test "returns a port by shortcode" do
      port = insert(:port, shortcode: "TEST")

      {:ok, found_port} = World.get_port_by_shortcode("TEST")

      assert found_port.id == port.id
    end

    test "returns an error if port is not found" do
      assert World.get_port_by_shortcode("NONE") == {:error, :not_found}
    end
  end

  describe "get_distance_between_ports/2" do
    test "returns the distance between two ports" do
      port1 = insert(:port)
      port2 = insert(:port)
      insert(:route, from: port1, to: port2, distance: 100)

      {:ok, distance} = World.get_distance_between_ports(port1, port2)

      assert distance == 100
    end

    test "returns an error if no route is found" do
      port1 = insert(:port)
      port2 = insert(:port)

      assert World.get_distance_between_ports(port1, port2) == {:error, :not_found}
    end
  end
end
