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
end
