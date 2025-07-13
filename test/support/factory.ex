defmodule Tradewinds.Factory do
  use ExMachina.Ecto, repo: Tradewinds.Repo

  def player_factory do
    %Tradewinds.Accounts.Player{
      name: "Test User",
      email: sequence(:email, &"user-#{&1}@example.com"),
      password: "password123",
      password_hash: Argon2.hash_pwd_salt("password123")
    }
  end

  def company_agent_factory do
    %Tradewinds.Companies.CompanyAgent{
      company: build(:company),
      port: build(:port)
    }
  end

  def trader_factory do
    %Tradewinds.Trading.Trader{
      name: "Test Trader",
      port: build(:port)
    }
  end

  def trader_inventory_factory do
    %Tradewinds.Trading.TraderInventory{
      trader: build(:trader),
      item: build(:item),
      stock: 100
    }
  end

  def trader_plan_factory do
    %Tradewinds.Trading.TraderPlan{
      trader: build(:trader),
      item: build(:item),
      average_acquisition_cost: 10,
      ideal_stock_level: 1000,
      target_profit_margin: 1.2,
      max_buy_sell_spread: 0.2,
      price_elasticity: 0.5,
      liquidity_factor: 0.5,
      consumption_rate: 10,
      reversion_rate: 0.1,
      regional_cost: 10
    }
  end

  def country_factory do
    %Tradewinds.World.Country{
      name: sequence(:name, &"Country #{&1}"),
      description: "A test country"
    }
  end

  def port_factory do
    %Tradewinds.World.Port{
      name: sequence(:name, &"Port #{&1}"),
      shortcode: sequence(:shortcode, &"P#{&1}"),
      country: build(:country)
    }
  end

  def company_factory do
    %Tradewinds.Companies.Company{
      name: sequence(:name, &"Company #{&1}"),
      ticker: sequence(:ticker, &"C#{&1}"),
      treasury: 1000,
      home_port_id: insert(:port).id
    }
  end

  def shipyard_factory do
    %Tradewinds.Shipyard{
      port: build(:port)
    }
  end

  def ship_factory do
    %Tradewinds.Ships.Ship{
      name: "The Black Pearl",
      state: :in_port,
      type: :cutter,
      capacity: 100,
      speed: 10,
      max_passengers: 10,
      port: build(:port),
      company: build(:company)
    }
  end

  def office_factory do
    %Tradewinds.Companies.Office{
      company: build(:company),
      port: build(:port)
    }
  end

  def warehouse_factory do
    %Tradewinds.Warehouses.Warehouse{
      company: build(:company),
      port: build(:port)
    }
  end

  def route_factory do
    %Tradewinds.World.Route{
      from: build(:port),
      to: build(:port),
      distance: 100
    }
  end

  def shipyard_inventory_factory do
    %Tradewinds.Shipyard.ShipyardInventory{
      shipyard: build(:shipyard),
      ship: build(:ship),
      cost: 10_000
    }
  end

  def item_factory do
    %Tradewinds.World.Item{
      name: sequence(:name, &"Item #{&1}"),
      shortcode: sequence(:shortcode, &"I#{&1}"),
      description: "A test item"
    }
  end

  def ship_inventory_factory do
    %Tradewinds.Ships.ShipInventory{
      ship: build(:ship),
      item: build(:item),
      amount: 10
    }
  end

  def warehouse_inventory_factory do
    %Tradewinds.Warehouses.WarehouseInventory{
      warehouse: insert(:warehouse),
      item: build(:item),
      amount: 10
    }
  end
end
