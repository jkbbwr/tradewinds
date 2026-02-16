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
      treasury: 100_000
    }
  end

  def director_factory do
    %Tradewinds.Companies.Director{
      company: build(:company),
      player: build(:player)
    }
  end
end
