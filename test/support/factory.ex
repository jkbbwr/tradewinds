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
      country_id: insert(:country).id
    }
  end

  def company_factory do
    %Tradewinds.Schema.Company{
      name: sequence(:name, &"Company #{&1}"),
      ticker: sequence(:ticker, &"C#{&1}"),
      treasury: 1000,
      home_port_id: build(:port).id
    }
  end
end
