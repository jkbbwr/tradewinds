defmodule Tradewinds.Schema.AuthToken do
  use Tradewinds.Schema

  schema "auth_token" do
    belongs_to :player, Tradewinds.Schema.Player
    field :token, :string

    timestamps()
  end
end
