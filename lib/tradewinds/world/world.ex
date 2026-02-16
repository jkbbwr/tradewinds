defmodule Tradewinds.World do
  @moduledoc """
  The World context.
  """

  import Ecto.Query, warn: false
  alias Tradewinds.Repo

  alias Tradewinds.World.Country
  alias Tradewinds.World.Port
  alias Tradewinds.World.Route

  def fetch_country(id) do
    Repo.get(Country, id) |> Repo.ok_or(:country_not_found)
  end

  def fetch_country_by_name(name) do
    Repo.get_by(Country, name: name) |> Repo.ok_or(:country_not_found)
  end

  def fetch_port(id) do
    Repo.get(Port, id) |> Repo.ok_or(:port_not_found)
  end

  def fetch_port_by_name(name) do
    Repo.get_by(Port, name: name) |> Repo.ok_or(:port_not_found)
  end

  def fetch_port_by_shortcode(shortcode) do
    Repo.get_by(Port, shortcode: shortcode) |> Repo.ok_or(:port_not_found)
  end

  def fetch_route(from, to) do
    Repo.get_by(Route, from_id: from.id, to_id: to.id)
    |> Repo.ok_or(:route_not_found)
  end

  def fetch_shipyard(id) do
    Repo.get(Shipyard, id)
    |> Repo.ok_or(:shipyard_not_found)
  end

  def fetch_shipyard_for_port(port) do
    Repo.get_by(Shipyard, port_id: port.id)
    |> Repo.ok_or(:shipyard_not_found)
  end
end
