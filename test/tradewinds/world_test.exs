defmodule Tradewinds.WorldTest do
  use Tradewinds.DataCase

  alias Tradewinds.World

  def country_fixture(attrs \\ %{}) do
    valid_attrs = %{name: "Test Country", description: "A test country description"}

    {:ok, country} =
      attrs
      |> Enum.into(valid_attrs)
      |> then(&Tradewinds.Repo.insert(struct(Tradewinds.World.Country, &1)))

    country
  end

  def port_fixture(country, attrs \\ %{}) do
    valid_attrs = %{name: "Test Port", shortcode: "TST"}

    {:ok, port} =
      attrs
      |> Enum.into(valid_attrs)
      |> Map.put(:country_id, country.id)
      |> then(&Tradewinds.Repo.insert(struct(Tradewinds.World.Port, &1)))

    port
  end

  def good_fixture(attrs \\ %{}) do
    valid_attrs = %{
      name: "Test Good",
      description: "Test Desc",
      category: "Test Cat",
      base_price: 100,
      volatility: 0.5,
      elasticity: 0.5
    }

    {:ok, good} =
      attrs
      |> Enum.into(valid_attrs)
      |> then(&Tradewinds.Repo.insert(struct(Tradewinds.World.Good, &1)))

    good
  end

  def ship_type_fixture(attrs \\ %{}) do
    valid_attrs = %{
      name: "Test Ship",
      description: "Desc",
      capacity: 100,
      speed: 10,
      base_price: 1000,
      upkeep: 100
    }

    {:ok, ship_type} =
      attrs
      |> Enum.into(valid_attrs)
      |> then(&Tradewinds.Repo.insert(struct(Tradewinds.World.ShipType, &1)))

    ship_type
  end

  describe "countries" do
    test "fetch_country/1 returns the country" do
      country = country_fixture()
      assert World.fetch_country(country.id) == {:ok, country}
    end

    test "fetch_country_by_name/1 returns the country" do
      country = country_fixture()
      assert World.fetch_country_by_name(country.name) == {:ok, country}
    end

    test "fetch_country/1 returns error if not found" do
      assert World.fetch_country(Ecto.UUID.generate()) == {:error, :country_not_found}
    end
  end

  describe "ports" do
    test "fetch_port/1 returns the port" do
      country = country_fixture()
      port = port_fixture(country)
      assert World.fetch_port(port.id) == {:ok, port}
    end

    test "fetch_port_by_name/1 returns the port" do
      country = country_fixture()
      port = port_fixture(country)
      assert World.fetch_port_by_name(port.name) == {:ok, port}
    end

    test "fetch_port_by_shortcode/1 returns the port" do
      country = country_fixture()
      port = port_fixture(country)
      assert World.fetch_port_by_shortcode(port.shortcode) == {:ok, port}
    end

    test "fetch_port/1 returns error if not found" do
      assert World.fetch_port(Ecto.UUID.generate()) == {:error, :port_not_found}
    end
  end

  describe "routes" do
    alias Tradewinds.World.Route

    test "fetch_route_by_id/1 returns the route" do
      country = country_fixture()
      p1 = port_fixture(country, %{name: "A", shortcode: "A"})
      p2 = port_fixture(country, %{name: "B", shortcode: "B"})
      {:ok, route} = Tradewinds.Repo.insert(%Route{from_id: p1.id, to_id: p2.id, distance: 100})

      assert World.fetch_route_by_id(route.id) == {:ok, route}
    end

    test "fetch_route/2 returns the route" do
      country = country_fixture()
      p1 = port_fixture(country, %{name: "A", shortcode: "A"})
      p2 = port_fixture(country, %{name: "B", shortcode: "B"})
      {:ok, route} = Tradewinds.Repo.insert(%Route{from_id: p1.id, to_id: p2.id, distance: 100})
      
      # Known bug: fetch_route/2 calls Repo.one() on a struct, causing Protocol.UndefinedError
      assert World.fetch_route(p1, p2) == {:ok, route}
    end
  end

  describe "goods" do
    test "fetch_good/1 returns the good" do
      good = good_fixture()
      assert World.fetch_good(good.id) == {:ok, good}
    end

    test "fetch_good_by_name/1 returns the good" do
      good = good_fixture()
      assert World.fetch_good_by_name(good.name) == {:ok, good}
    end

    test "fetch_good/1 returns error if not found" do
      assert World.fetch_good(Ecto.UUID.generate()) == {:error, :good_not_found}
    end
  end

  describe "ship_types" do
    test "fetch_ship_type/1 returns the ship type" do
      ship_type = ship_type_fixture()
      assert World.fetch_ship_type(ship_type.id) == {:ok, ship_type}
    end

    test "fetch_ship_type_by_name/1 returns the ship type" do
      ship_type = ship_type_fixture()
      assert World.fetch_ship_type_by_name(ship_type.name) == {:ok, ship_type}
    end

    test "fetch_ship_type/1 returns error if not found" do
      assert World.fetch_ship_type(Ecto.UUID.generate()) == {:error, :ship_type_not_found}
    end
  end
end