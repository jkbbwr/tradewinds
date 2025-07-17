defmodule Tradewinds.Warehouses.Warehouse do
  @moduledoc """
  Warehouse schema.
  """
  use Tradewinds.Schema
  import Ecto.Changeset

  alias Tradewinds.Companies.Company
  alias Tradewinds.World.Port

  schema "warehouse" do
    belongs_to :company, Company, foreign_key: :company_id
    belongs_to :port, Port, foreign_key: :port_id
    has_many :inventory, Tradewinds.Warehouses.WarehouseInventory, foreign_key: :warehouse_id

    timestamps()
  end

  @doc """
  Builds a changeset for the warehouse schema.
  """
  def create_changeset(warehouse, attrs) do
    warehouse
    |> cast(attrs, [:company_id, :port_id])
    |> validate_required([:company_id, :port_id])
    |> unique_constraint([:company_id, :port_id])
  end
end
