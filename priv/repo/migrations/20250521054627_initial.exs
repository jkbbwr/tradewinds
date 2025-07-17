defmodule Tradewinds.Repo.Migrations.Initial do
  use Ecto.Migration

  def change do
    create table(:player) do
      add :name, :text, null: false
      add :email, :text, null: false
      add :password_hash, :string, null: false
      add :enabled, :boolean, null: false, default: false

      timestamps()
    end

    create unique_index(:player, [:email])

    create table(:preference) do
      add :player_id, references(:player), null: false
      add :key, :text, null: false
      add :value, :text, null: false
    end

    create index(:preference, [:player_id, :key])

    create table(:country) do
      add :name, :text, null: false
      add :description, :text
      timestamps()
    end

    create table(:port) do
      add :name, :text, null: false
      add :shortcode, :text, null: false
      add :country_id, references(:country), null: false
      add :warehouse_cost, :integer, null: false, default: 10
      timestamps()
    end

    create unique_index(:port, :name)
    create unique_index(:port, :shortcode)

    create table(:company) do
      add :name, :text, null: false
      add :ticker, :string, size: 5, null: false
      add :treasury, :integer, null: false
      add :home_port_id, references(:port), null: false
      timestamps()
    end

    create unique_index(:company, [:name])
    create unique_index(:company, [:ticker])
    create unique_index(:company, [:name, :ticker])

    create table(:director) do
      add :company_id, references(:company), null: false
      add :player_id, references(:player), null: false
      timestamps()
    end

    create unique_index(:director, [:company_id, :player_id])

    create table(:office) do
      add :company_id, references(:company), null: false
      add :port_id, references(:port), null: false
      timestamps()
    end

    create unique_index(:office, [:company_id, :port_id])

    create table(:auth_token) do
      add :player_id, references(:player), null: false
      add :token, :text, null: false
      timestamps()
    end

    create unique_index(:auth_token, [:token])

    create table(:route) do
      add :from_id, references(:port), null: false
      add :to_id, references(:port), null: false
      add :distance, :integer, null: false
      timestamps()
    end

    create unique_index(:route, [:from_id, :to_id])
    create unique_index(:route, [:to_id, :from_id])

    create table(:ship) do
      add :name, :text, null: false
      add :state, :text, null: false
      add :type, :text, null: false
      add :capacity, :integer, null: false
      add :speed, :integer, null: false
      add :company_id, references(:company)
      add :port_id, references(:port)
      add :route_id, references(:route)
      add :arriving_at, :utc_datetime
      add :max_passengers, :integer, null: false
      timestamps()
    end

    create index(:ship, [:state])
    create index(:ship, [:type])
    create index(:ship, [:arriving_at])

    create constraint(:ship, "port_xor_route_constraint",
             check:
               "((port_id IS NOT NULL AND route_id IS NULL) OR (port_id IS NULL AND route_id IS NOT NULL))",
             comment: "a ship is either at sea or its in port. it cannot be neither."
           )

    create table(:modification) do
      add :ship_id, references(:ship), null: false
      timestamps()
    end

    create table(:shipyard) do
      add :port_id, references(:port), null: false
      timestamps()
    end

    create unique_index(:shipyard, :port_id)

    create table(:shipyard_inventory) do
      add :shipyard_id, references(:shipyard), null: false
      add :ship_id, references(:ship), null: false
      add :cost, :integer, null: false
    end

    create unique_index(:shipyard_inventory, [:shipyard_id, :ship_id])

    create table(:item) do
      add :name, :text, null: false
      add :shortcode, :text, null: false
      add :description, :text, null: false
      timestamps()
    end

    create unique_index(:item, :shortcode)

    create table(:ship_inventory) do
      add :item_id, references(:item), null: false
      add :ship_id, references(:ship), null: false
      add :amount, :integer, null: false
      timestamps()
    end

    create unique_index(:ship_inventory, [:ship_id, :item_id])

    create table(:warehouse) do
      add :company_id, references(:company), null: false
      add :port_id, references(:port), null: false
      timestamps()
    end

    create unique_index(:warehouse, [:company_id, :port_id],
             comment: "companies can only have one warehouse in each port"
           )

    create table(:warehouse_inventory) do
      add :warehouse_id, references(:warehouse), null: false
      add :item_id, references(:item), null: false
      add :amount, :integer, null: false
      timestamps()
    end

    create unique_index(:warehouse_inventory, [:warehouse_id, :item_id])

    create table(:trader) do
      add :port_id, references(:port), null: false
      add :name, :text, null: false
      timestamps()
    end

    create table(:trader_inventory) do
      add :trader_id, references(:trader), null: false
      add :item_id, references(:item), null: false
      add :stock, :integer, null: false
      timestamps()
    end

    create unique_index(:trader_inventory, [:trader_id, :item_id])

    create table(:trader_plan) do
      add :trader_id, references(:trader), null: false
      add :item_id, references(:item), null: false

      add :average_acquisition_cost, :integer,
        null: false,
        comment: "weighted average acquisition cost in the base currency."

      add :ideal_stock_level, :integer,
        null: false,
        comment: "the ideal stock level the trader wants to maintain."

      add :target_profit_margin, :float,
        null: false,
        comment: "target profit margin, e.g., 1.2 for a 20% markup."

      add :max_buy_sell_spread, :float,
        null: false,
        comment: "maximum buy/sell price spread, e.g., 0.4 for a 40% spread."

      add :price_elasticity, :float,
        null: false,
        comment: "price elasticity of the good, controls price sensitivity to supply."

      add :liquidity_factor, :float,
        null: false,
        comment:
          "liquidity factor for price impact, controls how much large trades affect the price."

      add :consumption_rate, :integer,
        null: false,
        comment: "the quantity of the good consumed each market tick."

      add :reversion_rate, :float,
        null: false,
        comment:
          "the rate at which the average cost reverts to the regional average (0.0 to 1.0)."

      add :regional_cost, :integer,
        null: false,
        comment: "the long-term regional average cost of the good in base currency."

      timestamps()
    end

    create index(:trader_plan, [:trader_id])
    create index(:trader_plan, [:item_id])

    create unique_index(:trader_plan, [:trader_id, :item_id])

    create table(:orderbook) do
      add :port_id, references(:port), null: false
      add :company_id, references(:company), null: false
      add :item_id, references(:item), null: false
      add :order, :text, null: false
      add :amount, :integer, null: false
      add :cost, :integer, null: false
      timestamps()
    end

    create index(:orderbook, [:port_id, :item_id])
    create index(:orderbook, [:company_id])
    create index(:orderbook, [:order])

    create table(:company_agent) do
      add :company_id, references(:company), null: false
      add :port_id, references(:port)
      add :ship_id, references(:ship)
      timestamps()
    end

    create unique_index(:company_agent, [:company_id, :port_id],
             comment: "companies can only have one agent in each port"
           )

    create constraint(:company_agent, "port_xor_ship_constraint",
             check:
               "((port_id IS NOT NULL AND ship_id IS NULL) OR (port_id IS NULL AND ship_id IS NOT NULL))"
           )

    create table(:passenger) do
      add :ship_id, references(:ship)
      add :passenger_id, :uuid
      # currently its just :company_agent
      add :type, :text
    end

    create table(:loan_requests) do
      timestamps()
    end

    create table(:npc_trade) do
      add :item_id, references(:item), null: false
      add :trader_id, references(:trader), null: false
      add :company_id, references(:company), null: false
      add :player_id, references(:player), null: false
      add :amount, :integer, null: false
      add :price, :integer, null: false
      add :game_tick, :integer, null: false
      add :action, :text, null: false, comment: "from the perspective of the player!"
      timestamps()
    end

    create table(:bug_report) do
      add :player_id, references(:player)
      add :report, :text, null: false
      timestamps()
    end

    create table(:feedback) do
      add :player_id, references(:player)
      add :feedback, :text, null: false
      timestamps()
    end

    create index(:npc_trade, [:item_id])
    create index(:npc_trade, [:trader_id])
    create index(:npc_trade, [:company_id])
    create index(:npc_trade, [:player_id])
    create index(:npc_trade, [:game_tick])
    create index(:npc_trade, [:item_id, :game_tick])
  end
end
