defmodule Tradewinds.Logistics.Warehouse do
  use Tradewinds.Schema
  import Ecto.Changeset

  schema "warehouse" do
    field :level, :integer
    field :capacity, :integer
    field :delinquent, :boolean, default: false

    belongs_to :port, Tradewinds.World.Port
    belongs_to :company, Tradewinds.Companies.Company

    timestamps()
  end

  @doc false
  def create_changeset(warehouse, attrs) do
    warehouse
    |> cast(attrs, [:level, :capacity, :delinquent, :port_id, :company_id])
    |> validate_required([:level, :capacity, :port_id, :company_id])
    |> validate_number(:level, greater_than: 0)
    |> validate_number(:capacity, greater_than: 0)
    |> foreign_key_constraint(:port_id)
    |> foreign_key_constraint(:company_id)
    |> unique_constraint([:port_id, :company_id], name: :warehouse_port_id_company_id_index)
    |> check_constraint(:level, name: :level_must_be_positive)
    |> check_constraint(:capacity, name: :capacity_must_be_positive)
  end
end
