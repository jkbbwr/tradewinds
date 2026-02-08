defmodule Tradewinds.Accounts.AuthToken do
  use Tradewinds.Schema

  schema "auth_token" do
    field :token, :string
    belongs_to :player, Tradewinds.Accounts.Player

    timestamps()
  end

  def create_changeset(auth_token, attrs) do
    auth_token
    |> cast(attrs, [:token, :player_id])
    |> validate_required([:token, :player_id])
    |> unique_constraint(:token)
  end
end
