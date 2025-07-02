defmodule Tradewinds.Schema.Warehouse do
  use Tradewinds.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias Tradewinds.Repo

  schema "warehouse" do
    field :locked, :boolean
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

  def update_capacity_changeset(warehouse, new_capacity) do
    warehouse
    |> cast(%{capacity: new_capacity}, [:capacity])
    |> validate_number(:capacity, greater_than_or_equal_to: 0)
    |> validate_required([:capacity])
    |> validate_capacity()
  end

  defp validate_capacity(changeset) do
    id = get_field(changeset, :id)
    capacity = get_field(changeset, :capacity)

    current =
      from(inv in Tradewinds.Schema.WarehouseInventory,
        where: inv.warehouse_id == ^id,
        select: coalesce(sum(inv.amount), 0)
      )
      |> Repo.one()

    if current > capacity do
      add_error(changeset, :capacity, "capacity is smaller than inventory total")
    else
      changeset
    end
  end
end
