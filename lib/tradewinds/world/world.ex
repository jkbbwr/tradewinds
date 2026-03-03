defmodule Tradewinds.World do
  @moduledoc """
  The World context.
  Provides read-only access to static world data like ports, goods, and routes.
  """

  import Ecto.Query, warn: false
  alias Tradewinds.Repo

  alias Tradewinds.World.Country
  alias Tradewinds.World.Port
  alias Tradewinds.World.Route
  alias Tradewinds.World.Good
  alias Tradewinds.World.ShipType

  @doc """
  Fetches a country by its ID.
  """
  def fetch_country(id) do
    Repo.get(Country, id) |> Repo.ok_or(:country_not_found)
  end

  @doc """
  Fetches a country by its exact name.
  """
  def fetch_country_by_name(name) do
    Repo.get_by(Country, name: name) |> Repo.ok_or(:country_not_found)
  end

  @doc """
  Fetches a port by its ID.
  """
  def fetch_port(id) do
    Repo.get(Port, id) |> Repo.ok_or(:port_not_found)
  end

  @doc """
  Fetches a port by its exact name.
  """
  def fetch_port_by_name(name) do
    Repo.get_by(Port, name: name) |> Repo.ok_or(:port_not_found)
  end

  @doc """
  Fetches a port by its unique shortcode.
  """
  def fetch_port_by_shortcode(shortcode) do
    Repo.get_by(Port, shortcode: shortcode) |> Repo.ok_or(:port_not_found)
  end

  @doc """
  Fetches a route by its ID.
  """
  def fetch_route_by_id(id) do
    Repo.get(Route, id) |> Repo.ok_or(:route_not_found)
  end

  @doc """
  Fetches a specific bidirectional route between two ports.
  """
  def fetch_route(from, to) do
    Repo.get_by(Route, from_id: from.id, to_id: to.id)
    |> Repo.ok_or(:route_not_found)
  end

  @doc """
  Fetches a specific good by its ID.
  """
  def fetch_good(id) do
    Repo.get(Good, id) |> Repo.ok_or(:good_not_found)
  end

  @doc """
  Fetches a specific good by its exact name.
  """
  def fetch_good_by_name(name) do
    Repo.get_by(Good, name: name) |> Repo.ok_or(:good_not_found)
  end

  @doc """
  Fetches a specific ship type by its ID.
  """
  def fetch_ship_type(id) do
    Repo.get(ShipType, id) |> Repo.ok_or(:ship_type_not_found)
  end

  @doc """
  Fetches a specific ship type by its exact name.
  """
  def fetch_ship_type_by_name(name) do
    Repo.get_by(ShipType, name: name) |> Repo.ok_or(:ship_type_not_found)
  end
end
