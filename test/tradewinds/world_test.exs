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

    test "fetch_route/2 returns the route" do
      country = country_fixture()
      p1 = port_fixture(country, %{name: "A", shortcode: "A"})
      p2 = port_fixture(country, %{name: "B", shortcode: "B"})
      {:ok, route} = Tradewinds.Repo.insert(%Route{from_id: p1.id, to_id: p2.id, distance: 100})
      
      # This test currently fails because fetch_route/2 has a bug (calls Repo.one() on a struct)
      assert World.fetch_route(p1, p2) == {:ok, route}
    end
  end
end