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
    Repo.get(Country, id) |> Repo.ok_or({:country_not_found, id})
  end

  @doc """
  Fetches a country by its exact name.
  """
  def fetch_country_by_name(name) do
    Repo.get_by(Country, name: name) |> Repo.ok_or({:country_not_found, name})
  end

  @doc """
  Fetches a port by its ID.
  """
  def fetch_port(id) do
    Repo.get(Port, id) |> Repo.ok_or({:port_not_found, id})
  end

  @doc """
  Fetches a port by its exact name.
  """
  def fetch_port_by_name(name) do
    Repo.get_by(Port, name: name) |> Repo.ok_or({:port_not_found, name})
  end

  @doc """
  Fetches a port by its unique shortcode.
  """
  def fetch_port_by_shortcode(shortcode) do
    Repo.get_by(Port, shortcode: shortcode) |> Repo.ok_or({:port_not_found, shortcode})
  end

  @doc """
  Fetches a route by its ID.
  """
  def fetch_route_by_id(id) do
    Repo.get(Route, id) |> Repo.ok_or({:route_not_found, id})
  end

  @doc """
  Fetches a specific bidirectional route between two ports.
  """
  def fetch_route(from, to) do
    Repo.get_by(Route, from_id: from.id, to_id: to.id)
    |> Repo.ok_or({:route_not_found, {from.id, to.id}})
  end

  @doc """
  Fetches a specific good by its ID.
  """
  def fetch_good(id) do
    Repo.get(Good, id) |> Repo.ok_or({:good_not_found, id})
  end

  @doc """
  Fetches a specific good by its exact name.
  """
  def fetch_good_by_name(name) do
    Repo.get_by(Good, name: name) |> Repo.ok_or({:good_not_found, name})
  end

  @doc """
  Fetches a specific ship type by its ID.
  """
  def fetch_ship_type(id) do
    Repo.get(ShipType, id) |> Repo.ok_or({:ship_type_not_found, id})
  end

  @doc """
  Fetches a specific ship type by its exact name.
  """
  def fetch_ship_type_by_name(name) do
    Repo.get_by(ShipType, name: name) |> Repo.ok_or({:ship_type_not_found, name})
  end

  @doc """
  Lists all ports in the world.
  """
  def list_ports(params \\ %{}) do
    opts =
      params
      |> Map.take([:after, :before, :limit])
      |> Map.to_list()
      |> Keyword.merge(cursor_fields: [inserted_at: :asc, id: :asc], limit: 50)

    query = Port

    query =
      if country_id = params[:country_id], do: where(query, country_id: ^country_id), else: query

    query =
      if not is_nil(is_hub = params[:is_hub]), do: where(query, is_hub: ^is_hub), else: query

    query
    |> order_by(asc: :inserted_at, asc: :id)
    |> Repo.paginate(opts)
  end

  @doc """
  Lists all goods in the world.
  """
  def list_goods(params \\ %{}) do
    query = Good
    query = if category = params[:category], do: where(query, category: ^category), else: query
    Repo.all(query)
  end

  @doc """
  Lists all ship types in the world.
  """
  def list_ship_types do
    Repo.all(ShipType)
  end

  @doc """
  Lists all routes in the world.
  """
  def list_routes(params \\ %{}) do
    opts =
      params
      |> Map.take([:after, :before, :limit])
      |> Map.to_list()
      |> Keyword.merge(cursor_fields: [inserted_at: :asc, id: :asc], limit: 50)

    query = Route
    query = if from_id = params[:from_id], do: where(query, from_id: ^from_id), else: query
    query = if to_id = params[:to_id], do: where(query, to_id: ^to_id), else: query

    query
    |> order_by(asc: :inserted_at, asc: :id)
    |> Repo.paginate(opts)
  end

  @doc """
  Emits telemetry stats for the World context.
  """
  def emit_stats do
    stats = %{
      ports_count: Repo.aggregate(Port, :count, :id),
      countries_count: Repo.aggregate(Country, :count, :id)
    }

    :telemetry.execute([:tradewinds, :world, :stats], stats)
  end
end
