defmodule Tradewinds.World do
  @moduledoc """
  The World context.
  Defines the game world, including ports, countries, and routes.
  """

  alias Tradewinds.WorldRepo

  defdelegate fetch_port_by_name(name), to: WorldRepo
  defdelegate fetch_port_by_shortcode(shortcode), to: WorldRepo
  defdelegate get_ports_by_country(country), to: WorldRepo
  defdelegate fetch_country_by_name(name), to: WorldRepo
  defdelegate fetch_item_by_id(id), to: WorldRepo
  defdelegate fetch_distance_between_ports(port1, port2), to: WorldRepo
end