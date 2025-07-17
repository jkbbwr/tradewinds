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

  def find_route(origin_id, destination_id) do
    from(r in Route,
      where:
        (r.from_id == ^origin_id and r.to_id == ^destination_id) or
          (r.from_id == ^destination_id and r.to_id == ^origin_id)
    )
    |> Repo.one()
    |> Repo.ok_or(:route_not_found)
  end

  def fetch_item(id) do
    Repo.get(Item, id) |> Repo.ok_or(:item_not_found)
  end

  def list_ports, do: Repo.all(Port)

  def list_countries, do: Repo.all(Country)

  def fetch_port(id) do
    Repo.get(Port, id) |> Repo.ok_or(:port_not_found)
  end

  def fetch_country(id) do
    Repo.get(Country, id) |> Repo.ok_or(:country_not_found)
  end

  def create_port(name, shortcode, country_id) do
    %Port{}
    |> Port.create_changeset(%{
      name: name,
      shortcode: shortcode,
      country_id: country_id
    })
    |> Repo.insert()
  end

  def create_country(name, description) do
    %Country{}
    |> Country.create_changeset(%{name: name, description: description})
    |> Repo.insert()
  end

  def create_route(from_id, to_id, distance) do
    %Route{}
    |> Route.changeset(%{from_id: from_id, to_id: to_id, distance: distance})
    |> Repo.insert()
  end

  def routes_from(port_id) do
    from(r in Route, where: r.from_id == ^port_id or r.to_id == ^port_id) |> Repo.all()
  end
end
