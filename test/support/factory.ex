defmodule Tradewinds.Factory do
  use ExMachina.Ecto, repo: Tradewinds.Repo

  def player_factory do
    %Tradewinds.Accounts.Player{
      name: sequence(:name, &"Player #{&1}"),
      email: sequence(:email, &"player-#{&1}@example.com"),
      password: "password1234",
      password_hash: Argon2.hash_pwd_salt("password1234"),
      enabled: true
    }
  end

  def auth_token_factory do
    %Tradewinds.Accounts.AuthToken{
      token: sequence(:token, &"token-#{&1}"),
      player: build(:player)
    }
  end

  def company_factory do
    %Tradewinds.Companies.Company{
      name: sequence(:company_name, &"Company #{&1}"),
      ticker: sequence(:ticker, &"C#{&1}"),
      treasury: 100_000,
      home_port: build(:port)
    }
  end

  def director_factory do
    %Tradewinds.Companies.Director{
      company: build(:company),
      player: build(:player)
    }
  end

  def country_factory do
    %Tradewinds.World.Country{
      name: sequence(:country_name, &"Country #{&1}"),
      description: "A nice place."
    }
  end

  def port_factory do
    %Tradewinds.World.Port{
      name: sequence(:port_name, &"Port #{&1}"),
      shortcode: sequence(:port_code, &"P#{&1}"),
      country: build(:country)
    }
  end

  def ship_type_factory do
    %Tradewinds.World.ShipType{
      name: sequence(:ship_type_name, &"ShipType #{&1}"),
      description: "A sturdy vessel.",
      capacity: 100,
      passengers: 10,
      speed: 10,
      base_price: 1000,
      upkeep: 100
    }
  end

  def ship_factory do
    %Tradewinds.Fleet.Ship{
      name: sequence(:ship_name, &"Ship #{&1}"),
      status: :docked,
      company: build(:company),
      ship_type: build(:ship_type),
      port: build(:port)
    }
  end

  def route_factory do
    %Tradewinds.World.Route{
      distance: 100,
      from: build(:port),
      to: build(:port)
    }
  end

  def good_factory do
    %Tradewinds.World.Good{
      name: sequence(:good_name, &"Good #{&1}"),
      description: "A very valuable good.",
      category: "food",
      base_price: 100,
      volatility: 0.1,
      elasticity: 0.5
    }
  end

  def ship_cargo_factory do
    %Tradewinds.Fleet.ShipCargo{
      ship: build(:ship),
      good: build(:good),
      quantity: 10
    }
  end

  def warehouse_factory do
    %Tradewinds.Logistics.Warehouse{
      level: 1,
      capacity: 1000,
      delinquent: false,
      port: build(:port),
      company: build(:company)
    }
  end

  def warehouse_inventory_factory do
    %Tradewinds.Logistics.WarehouseInventory{
      warehouse: build(:warehouse),
      good: build(:good),
      quantity: 100
    }
  end

  def shipyard_factory do
    %Tradewinds.Shipyards.Shipyard{
      port: build(:port)
    }
  end

  def inventory_factory do
    %Tradewinds.Shipyards.Inventory{
      shipyard: build(:shipyard),
      ship_type: build(:ship_type),
      ship: build(:ship),
      cost: 1000
    }
  end

  def trader_factory do
    %Tradewinds.Commerce.Trader{
      name: sequence(:trader_name, &"Trader #{&1}")
    }
  end

  def trader_position_factory do
    %Tradewinds.Commerce.TraderPosition{
      trader: build(:trader),
      port: build(:port),
      good: build(:good),
      stock: 100,
      target_stock: 100,
      supply_rate: 0.1,
      demand_rate: 0.05,
      elasticity: 0.12,
      spread: 0.05,
      monthly_profit: 0
    }
  end

  def trade_log_factory do
    %Tradewinds.Economy.TradeLog{
      tick: 1,
      quantity: 10,
      price: 100,
      source: :npc_trader,
      port: build(:port),
      good: build(:good),
      buyer_id: Ecto.UUID.generate(),
      seller_id: Ecto.UUID.generate()
    }
  end

  def shock_factory do
    %Tradewinds.Economy.Shock{
      name: sequence(:shock_name, &"Shock #{&1}"),
      status: :active,
      start_tick: 0,
      demand_modifier: 10_000,
      supply_modifier: 10_000,
      price_modifier: 10_000,
      volatility_modifier: 10_000
    }
  end
end
