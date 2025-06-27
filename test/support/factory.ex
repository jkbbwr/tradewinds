defmodule Tradewinds.Factory do
  use ExMachina.Ecto, repo: Tradewinds.Repo

  def user_factory do
    %Tradewinds.Schema.Player{
      name: "Test User",
      email: sequence(:email, &"user-#{&1}@example.com"),
      password: "password123",
      password_hash: Argon2.hash_pwd_salt("password123")
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
end
