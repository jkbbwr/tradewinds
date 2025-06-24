defmodule Tradewinds.Factory do
  use ExMachina.Ecto, repo: Tradewinds.Repo

  def user_factory do
    %Tradewinds.Schema.Player{
      name: "Test",
      email: "test@test.com",
      password_hash:
        "$argon2id$v=19$m=65536,t=3,p=4$tY4/ZdNXFCNj2Kl4cYdChw$5V6CJnp6q5/ZzwL9WA481DPhwU0xgVvEGbnjSoPFIKw"
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
      country_id: build(:country).id
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
