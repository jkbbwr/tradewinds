defmodule Tradewinds.Factory do
  use ExMachina.Ecto, repo: Tradewinds.Repo

  def player_factory do
    %Tradewinds.Schema.Player{
      name: "Test User",
      email: sequence(:email, &"user-#{&1}@example.com"),
      password: "password123",
      password_hash: Argon2.hash_pwd_salt("password123")
    }
  end

  def company_agent_factory do
    %Tradewinds.Schema.CompanyAgent{
      company: build(:company),
      port: build(:port)
    }
  end

  def trader_factory do
    %Tradewinds.Schema.Trader{
      name: "Test Trader"
    }
  end

  def trader_inventory_factory do
    %Tradewinds.Schema.TraderInventory{
      trader: build(:trader),
      item: build(:item),
      stock: 100
    }
  end

  def trader_plan_factory do
    %Tradewinds.Schema.TraderPlan{
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
    %Tradewinds.Schema.Country{
      name: sequence(:name, &"Country #{&1}"),
      description: "A test country"
    }
  end

  def port_factory do
    %Tradewinds.Schema.Port{
      name: sequence(:name, &"Port #{&1}"),
      shortcode: sequence(:shortcode, &"P#{&1}"),
      country: build(:country)
    }
  end

  def company_factory do
    %Tradewinds.Schema.Company{
      name: sequence(:name, &"Company #{&1}"),
      ticker: sequence(:ticker, &"C#{&1}"),
      treasury: 1000,
      home_port_id: insert(:port).id
    }
  end

  def shipyard_factory do
    %Tradewinds.Schema.Shipyard{
      port: build(:port)
    }
  end

  def ship_factory do
    %Tradewinds.Schema.Ship{
      name: "The Black Pearl",
      state: :in_port,
      type: :cutter,
      capacity: 100,
      speed: 10,
      port: build(:port)
    }
  end

  def office_factory do
    %Tradewinds.Schema.Office{
      company: build(:company),
      port: build(:port)
    }
  end

  def warehouse_factory do
    %Tradewinds.Schema.Warehouse{
      company: build(:company),
      port: build(:port),
      capacity: 1000
    }
  end

  def route_factory do
    %Tradewinds.Schema.Route{
      from: build(:port),
      to: build(:port),
      distance: 100
    }
  end

  def shipyard_inventory_factory do
    %Tradewinds.Schema.ShipyardInventory{
      shipyard: build(:shipyard),
      ship: build(:ship),
      cost: 10_000
    }
  end

  def item_factory do
    %Tradewinds.Schema.Item{
      name: sequence(:name, &"Item #{&1}"),
      shortcode: sequence(:shortcode, &"I#{&1}"),
      description: "A test item"
    }
  end

  def ship_inventory_factory do
    %Tradewinds.Schema.ShipInventory{
      ship: build(:ship),
      item: build(:item),
      amount: 10
    }
  end

  def warehouse_inventory_factory do
    %Tradewinds.Schema.WarehouseInventory{
      warehouse: build(:warehouse),
      item: build(:item),
      amount: 10
    }
  end
end
