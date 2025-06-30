defmodule Tradewinds.World do
  @moduledoc """
  The World context.
  Defines the game world, including ports, countries, and routes.
  """

  alias Tradewinds.Repo
  alias Tradewinds.Schema.Port
  alias Tradewinds.Schema.Country
  alias Tradewinds.Schema.Route
  import Ecto.Query

  def get_port_by_name(name) do
    Repo.fetch_by(Port, name: name)
  end

  def get_port_by_shortcode(shortcode) do
    Repo.fetch_by(Port, shortcode: shortcode)
  end

  def get_ports_by_country(country) do
    Repo.all(
      from p in Port,
        where: p.country_id == ^country.id
    )
  end

  def get_country_by_name(name) do
    Repo.fetch_by(Country, name: name)
  end

  def get_item_by_id(id) do
    Repo.fetch_by(Item, id: id)
  end

  def get_distance_between_ports(port1, port2) do
    query =
      from(r in Route,
        where:
          (r.from_id == ^port1.id and r.to_id == ^port2.id) or
            (r.from_id == ^port2.id and r.to_id == ^port1.id),
        select: r.distance
      )

    Repo.fetch_one(query)
  end
end
