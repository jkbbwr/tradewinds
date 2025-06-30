defmodule Tradewinds.Schema.Warehouse do
  use Tradewinds.Schema
  import Ecto.Changeset

  schema "warehouse" do
    field :capacity, :integer
    belongs_to :company, Tradewinds.Schema.Company, foreign_key: :company_id
    belongs_to :port, Tradewinds.Schema.Port, foreign_key: :port_id
    has_many :inventory, Tradewinds.Schema.WarehouseInventory, foreign_key: :warehouse_id

    timestamps()
  end

  @doc """
  Builds a changeset for the warehouse schema.
  """
  def create_changeset(warehouse, attrs) do
    warehouse
    |> cast(attrs, [:capacity, :company_id, :port_id])
    |> validate_required([:capacity, :company_id, :port_id])
    |> unique_constraint([:company_id, :port_id])
  end
end
