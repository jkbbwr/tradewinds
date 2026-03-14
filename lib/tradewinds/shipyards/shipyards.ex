defmodule Tradewinds.Shipyards do
  @moduledoc """
  The Shipyards context.
  Handles ship construction, shipyard inventory, and player ship purchasing.
  """

  import Ecto.Query, warn: false
  alias Tradewinds.Repo
  alias Tradewinds.Companies
  alias Tradewinds.Fleet
  alias Tradewinds.Shipyards.Shipyard
  alias Tradewinds.Shipyards.Inventory
  alias Tradewinds.Scope

  @doc """
  Fetches a shipyard by its ID.
  """
  def fetch_shipyard(id) do
    Repo.get(Shipyard, id)
    |> Repo.ok_or({:shipyard_not_found, id})
  end

  @doc """
  Fetches the shipyard associated with a specific port ID.
  """
  def fetch_shipyard_for_port(port_id) do
    Repo.get_by(Shipyard, port_id: port_id)
    |> Repo.ok_or({:shipyard_not_found, port_id})
  end

  @doc """
  Fetches all available inventory (unowned ships) currently for sale at a shipyard.
  """
  def fetch_shipyard_inventory(shipyard_id) do
    with {:ok, _shipyard} <- fetch_shipyard(shipyard_id) do
      inventory =
        Inventory
        |> where(shipyard_id: ^shipyard_id)
        |> Repo.all()

      {:ok, inventory}
    end
  end

  @doc """
  Checks if a shipyard has at least one ship of a specific type in stock.
  Returns boolean or an error if the shipyard doesn't exist.
  """
  def has_stock?(shipyard_id, ship_type_id) do
    query =
      from s in Shipyard,
        where: s.id == ^shipyard_id,
        left_join: inv in Inventory,
        on: inv.shipyard_id == s.id and inv.ship_type_id == ^ship_type_id,
        select: not is_nil(inv.id),
        limit: 1

    case Repo.one(query) do
      nil -> {:error, :shipyard_not_found}
      has_stock -> has_stock
    end
  end

  @doc """
  Atomically purchases a ship from a shipyard, assigning it to the company
  and deducting the cost from the company's treasury.
  """
  def purchase_ship(%Scope{company_id: company_id}, shipyard_id, ship_type_id) do
    Repo.transact(fn ->
      with {:ok, company} <- Companies.fetch_company(company_id),
           {:ok, :active} <- Companies.is_active?(company),
           {:ok, shipyard} <- fetch_shipyard(shipyard_id),
           {:ok, inventory} <- fetch_inventory_for_update(shipyard_id, ship_type_id),
           {:ok, ship} <- Fleet.assign_ship(inventory.ship_id, company_id),
           {:ok, _inventory} <- Repo.delete(inventory),
           now = DateTime.utc_now(),
           tax_amount <-
             Tradewinds.Economy.calculate_tax_for_port(inventory.cost, shipyard.port_id),
           {:ok, _company} <-
             Companies.record_transaction(
               company_id,
               -inventory.cost,
               :ship_purchase,
               :ship,
               inventory.ship_id,
               now,
               meta: %{
                 shipyard_id: shipyard_id,
                 ship_type_id: ship_type_id,
                 cost: inventory.cost
               }
             ),
           {:ok, _company} <-
             (if tax_amount > 0 do
                Companies.record_transaction(
                  company_id,
                  -tax_amount,
                  :tax,
                  :ship,
                  inventory.ship_id,
                  now,
                  meta: %{base_amount: inventory.cost, port_id: shipyard.port_id}
                )
              else
                {:ok, :no_tax}
              end) do
        Tradewinds.Events.broadcast_ship_bought(ship)
        {:ok, ship}
      end
    end)
  end

  defp fetch_inventory_for_update(shipyard_id, ship_type_id) do
    Inventory
    |> where(shipyard_id: ^shipyard_id, ship_type_id: ^ship_type_id)
    |> limit(1)
    |> lock("FOR UPDATE")
    |> Repo.one()
    |> Repo.ok_or({:inventory_not_found, ship_type_id})
  end

  def fetch_ship_type(id) do
    Tradewinds.World.ShipType
    |> where(id: ^id)
    |> Repo.one()
    |> Repo.ok_or({:ship_type_not_found, id})
  end

  @doc """
  Calculates the current buy-back price for a ship type at a specific shipyard.
  Formula: 90% base price if 0 in stock, decreasing by 10% per ship in stock, min 40%.
  """
  def calculate_sell_price(ship_type_id, shipyard_id) do
    with {:ok, ship_type} <- fetch_ship_type(ship_type_id) do
      count =
        Inventory
        |> where(shipyard_id: ^shipyard_id, ship_type_id: ^ship_type_id)
        |> Repo.aggregate(:count, :id)

      # 0 ships: 0.9, 1: 0.8, 2: 0.7, 3: 0.6, 4: 0.5, 5+: 0.4
      factor = max(0.4, 0.9 - count * 0.1)
      price = floor(ship_type.base_price * factor)

      {:ok, price}
    end
  end

  @doc """
  Sells a ship back to a shipyard at a variable loss.
  The ship must be empty and docked at the shipyard's port.
  """
  def sell_ship(%Scope{company_id: company_id}, shipyard_id, ship_id) do
    Repo.transact(fn ->
      with {:ok, shipyard} <- fetch_shipyard(shipyard_id),
           {:ok, ship} <-
             Fleet.fetch_company_ship(%Scope{company_id: company_id}, ship_id,
               preload: [:ship_type]
             ),
           :ok <- validate_ship_at_shipyard(ship, shipyard),
           :ok <- validate_ship_empty(ship),
           {:ok, price} <- calculate_sell_price(ship.ship_type_id, shipyard_id),
           {:ok, _} <- Fleet.release_ship(ship_id),
           {:ok, _} <-
             create_ship(shipyard_id, ship.ship_type_id, ship_id, ship.ship_type.base_price),
           now = DateTime.utc_now(),
           {:ok, company} <-
             Companies.record_transaction(
               company_id,
               price,
               :ship_sale,
               :ship,
               ship_id,
               now,
               meta: %{
                 shipyard_id: shipyard_id,
                 ship_type_id: ship.ship_type_id,
                 price: price
               }
             ) do
        Tradewinds.Events.broadcast_ship_sold(company_id, ship)
        {:ok, %{price: price, company: company}}
      end
    end)
  end

  defp validate_ship_at_shipyard(ship, shipyard) do
    if ship.port_id == shipyard.port_id and ship.status == :docked do
      :ok
    else
      {:error, :not_at_shipyard}
    end
  end

  defp validate_ship_empty(ship) do
    with {:ok, total} <- Fleet.current_cargo_total(ship.id) do
      if total == 0 do
        :ok
      else
        {:error, :ship_not_empty}
      end
    end
  end

  @doc """
  Seeds a newly built, unowned ship into a shipyard's inventory.
  """
  def create_ship(shipyard_id, ship_type_id, ship_id, cost) do
    %Inventory{}
    |> Inventory.create_changeset(%{
      shipyard_id: shipyard_id,
      ship_type_id: ship_type_id,
      ship_id: ship_id,
      cost: cost
    })
    |> Repo.insert()
  end

  @doc """
  Produces ships at a specific shipyard to maintain stock levels.
  Ensures a minimum stock of 2 for each ship type.
  Bigger ships (higher capacity) take proportionally longer to build based on a weekly probability roll.
  """
  def produce_ships(shipyard_id) do
    with {:ok, shipyard} <- fetch_shipyard(shipyard_id),
         ship_types <- Repo.all(Tradewinds.World.ShipType),
         {:ok, result} <-
           Repo.transact(fn ->
             Enum.each(ship_types, fn type ->
               count =
                 Inventory
                 |> where(shipyard_id: ^shipyard.id, ship_type_id: ^type.id)
                 |> Repo.aggregate(:count, :id)

               # Calculate production ratio. Base capacity of 120 produces 1 ship/week on average.
               # Smaller ships (e.g. 40 capacity) produce 3 ships/week.
               # Larger ships (e.g. 240 capacity) produce 0.5 ships/week.
               ratio = 120.0 / max(type.capacity, 1)

               base_to_build = floor(ratio)
               chance_for_extra = ratio - base_to_build

               potential_volume =
                 base_to_build + if :rand.uniform() <= chance_for_extra, do: 1, else: 0

               # Clamp production by the target stock (3)
               to_build = min(potential_volume, max(0, 3 - count))

               if to_build > 0 do
                 Enum.each(1..to_build, fn _ -> build_ship_for_inventory(shipyard, type) end)
               end
             end)

             {:ok, :produced}
           end) do
      {:ok, result}
    end
  end

  defp build_ship_for_inventory(shipyard, ship_type) do
    ship_name = "#{ship_type.name} - #{Ecto.UUID.generate() |> String.slice(0..7)}"

    with {:ok, ship} <-
           %Tradewinds.Fleet.Ship{}
           |> Tradewinds.Fleet.Ship.create_changeset(%{
             name: ship_name,
             status: :docked,
             port_id: shipyard.port_id,
             ship_type_id: ship_type.id,
             company_id: nil
           })
           |> Repo.insert() do
      create_ship(shipyard.id, ship_type.id, ship.id, ship_type.base_price)
    end
  end
end
