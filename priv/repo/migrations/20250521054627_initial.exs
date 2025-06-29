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
      # add :crew, :integer, null: false
      # add :supplies, :integer, null: false
      add :capacity, :integer, null: false
      add :speed, :integer, null: false
      add :company_id, references(:company)
      add :port_id, references(:port)
      add :route_id, references(:route)
      add :arriving_at, :utc_datetime
      timestamps()
    end

    create constraint(:ship, "port_xor_route_constraint",
             check:
               "((port_id IS NOT NULL AND route_id IS NULL) OR (port_id IS NULL AND route_id IS NOT NULL))"
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

    create table(:warehouse) do
      add :capacity, :integer, null: false
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
      add :cost, :integer, null: false
      add :desire, :integer, null: false
      timestamps()
    end

    create table(:orderbook) do
      add :port_id, references(:port), null: false
      add :company_id, references(:company), null: false
      add :item_id, references(:item), null: false
      add :order, :text, null: false
      add :amount, :integer, null: false
      add :cost, :integer, null: false
      timestamps()
    end

    create table(:company_agent) do
      add :company_id, references(:company), null: false
      add :port_id, references(:port), null: false
      add :ship_id, references(:shi), null: false
      timestamps()
    end

    create unique_index(:company_agent, [:company_id, :port_id],
             comment: "companies can only have one agent in each port"
           )

    create constraint(:company_agent, "port_xor_ship_constraint",
             check:
               "((port_id IS NOT NULL AND ship_id IS NULL) OR (port_id IS NULL AND ship_id IS NOT NULL))"
           )
  end
end
