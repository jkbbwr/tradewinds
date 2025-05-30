defmodule Tradewinds.Schema.AuthToken do
  use Tradewinds.Schema
  import Ecto.Changeset

  schema "auth_token" do
    belongs_to :player, Tradewinds.Schema.Player
    field :token, :string

    timestamps()
  end

  @doc """
  Builds a changeset for the auth_token schema.
  """
  def changeset(authToken, attrs) do
    authToken
    |> cast(attrs, [:player_id, :token])
    |> validate_required([:player_id, :token])
    |> unique_constraint(:token)
  end
end
