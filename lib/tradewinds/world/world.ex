defmodule Tradewinds.World do
  @moduledoc """
  The World context.
  Defines the game world, including ports, countries, and routes.
  """
  alias Tradewinds.Repo
  alias Tradewinds.World.Country
  alias Tradewinds.World.Item
  alias Tradewinds.World.Port
  alias Tradewinds.World.Route
  import Ecto.Query

  @doc """
  Finds a route between two ports.
  """
  def find_route(origin_id, destination_id) do
    from(r in Route,
      where:
        (r.from_id == ^origin_id and r.to_id == ^destination_id) or
          (r.from_id == ^destination_id and r.to_id == ^origin_id)
    )
    |> Repo.one()
    |> Repo.ok_or(:route_not_found)
  end

  @doc """
  Fetches an item by its ID.
  """
  def fetch_item(id) do
    Repo.get(Item, id) |> Repo.ok_or(:item_not_found)
  end

  @doc """
  Lists all ports in the world.
  """
  def list_ports, do: Repo.all(Port)

  @doc """
  Lists all countries in the world.
  """
  def list_countries, do: Repo.all(Country)

  @doc """
  Fetches a port by its ID.
  """
  def fetch_port(id) do
    Repo.get(Port, id) |> Repo.ok_or(:port_not_found)
  end

  @doc """
  Fetches a country by its ID.
  """
  def fetch_country(id) do
    Repo.get(Country, id) |> Repo.ok_or(:country_not_found)
  end

  @doc """
  Creates a new port.
  """
  def create_port(name, shortcode, country_id) do
    %Port{}
    |> Port.create_changeset(%{
      name: name,
      shortcode: shortcode,
      country_id: country_id
    })
    |> Repo.insert()
  end

  @doc """
  Creates a new country.
  """
  def create_country(name, description) do
    %Country{}
    |> Country.create_changeset(%{name: name, description: description})
    |> Repo.insert()
  end

  @doc """
  Creates a new route between two ports.
  """
  def create_route(from_id, to_id, distance) do
    %Route{}
    |> Route.changeset(%{from_id: from_id, to_id: to_id, distance: distance})
    |> Repo.insert()
  end

  @doc """
  Returns all routes originating from a given port.
  """
  def routes_from(port_id) do
    from(r in Route, where: r.from_id == ^port_id or r.to_id == ^port_id) |> Repo.all()
  end
end
