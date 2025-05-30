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
end
