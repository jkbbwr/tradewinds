defmodule Tradewinds.Fleet do
  @moduledoc """
  The Fleet context.
  """

  import Ecto.Query, warn: false
  alias Tradewinds.Repo
  alias Tradewinds.Fleet.Ship
  alias Tradewinds.Scope

  def sail_ship() do
  end

  def dock_ship() do
  end

  def load_cargo() do
  end

  def unload_cargo() do
  end

  def fetch_ship(id) do
    Repo.get(Ship, id)
    |> Repo.ok_or(:ship_not_found)
  end

  def rename_ship(%Scope{} = scope, ship_id, new_name) do
    with {:ok, ship} <- fetch_ship(ship_id),
         true <- Scope.authorizes?(scope, ship.company_id) do
      ship |> Ship.change_name_changeset(new_name) |> Repo.update()
    end
  end

  def assign_ship(ship_id, company_id) do
    case fetch_ship(ship_id) do
      {:ok, ship} -> Ship.transfer_changeset(ship, company_id) |> Repo.update()
      err -> err
    end
  end

  def transfer_ship(%Scope{} = scope, ship_id, new_company_id) do
    with {:ok, ship} <- fetch_ship(ship_id),
         true <- Scope.authorizes?(scope, ship.company_id) do
      ship |> Ship.transfer_changeset(new_company_id) |> Repo.update()
    end
  end
end
