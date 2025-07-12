defmodule Tradewinds.Warehouse do
  use Tradewinds.Schema
  import Ecto.Changeset

  alias Tradewinds.Companies.Company
  alias Tradewinds.World.Port
  alias Tradewinds.Repo

  schema "warehouse" do
    belongs_to :company, Company, foreign_key: :company_id
    belongs_to :port, Port, foreign_key: :port_id
    has_many :inventory, Tradewinds.Warehouse.WarehouseInventory, foreign_key: :warehouse_id

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

  def store(warehouse, item, amount) do
    Repo.insert!(
      %Tradewinds.Warehouse.WarehouseInventory{warehouse_id: warehouse.id, item_id: item.id, amount: amount},
      on_conflict: [inc: [amount: amount]],
      conflict_target: [:warehouse_id, :item_id]
    )

    {:ok, :stored}
  end

  def withdraw(warehouse, item, amount) do
    Repo.transact(fn ->
      with {:ok, inventory} <- fetch_inventory_by_item_id(warehouse, item) do
        cond do
          inventory.amount == amount ->
            Repo.delete(inventory)

          inventory.amount < amount ->
            {:error, :not_enough_inventory}

          inventory.amount > amount ->
            inventory
            |> Tradewinds.Warehouse.WarehouseInventory.update_amount_changeset(inventory.amount - amount)
            |> Repo.update()
        end
      end
    end)
  end

  defp fetch_inventory_by_item_id(warehouse, item) do
    Repo.get_by(Tradewinds.Warehouse.WarehouseInventory, warehouse_id: warehouse.id, item_id: item.id)
    |> Repo.ok_or(:warehouse_inventory_not_found)
  end
end
