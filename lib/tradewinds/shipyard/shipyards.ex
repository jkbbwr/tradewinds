defmodule Tradewinds.Shipyards do
  alias Tradewinds.Repo
  alias Tradewinds.Shipyard

  def create_shipyard(port_id) do
    %Shipyard{}
    |> Shipyard.create_changeset(%{port_id: port_id})
    |> Repo.insert()
  end
end