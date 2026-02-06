defmodule Tradewinds.Factory do
  use ExMachina.Ecto, repo: Tradewinds.Repo

  def player_factory do
    %Tradewinds.Players.Player{
      name: sequence(:name, &"Player #{&1}"),
      email: sequence(:email, &"player-#{&1}@example.com"),
      password: "password1234",
      password_hash: Argon2.hash_pwd_salt("password1234"),
      enabled: true
    }
  end

  def auth_token_factory do
    %Tradewinds.Auth.AuthToken{
      token: sequence(:token, &"token-#{&1}"),
      player: build(:player)
    }
  end
end
