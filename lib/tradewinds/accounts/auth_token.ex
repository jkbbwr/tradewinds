defmodule Tradewinds.Accounts.AuthToken do
  use Tradewinds.Schema

  schema "auth_token" do
    belongs_to :player, Tradewinds.Accounts.Player
    field :token, :string

    timestamps()
  end
end
