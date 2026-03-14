defmodule Tradewinds.Accounts.AuthToken do
  use Tradewinds.Schema

  schema "auth_token" do
    field :token, :string
    field :is_read_only, :boolean, default: false
    belongs_to :player, Tradewinds.Accounts.Player

    timestamps()
  end

  @doc """
  Builds a changeset for persisting a generated auth token.
  """
  def create_changeset(auth_token, attrs) do
    auth_token
    |> cast(attrs, [:token, :player_id, :is_read_only])
    |> validate_required([:token, :player_id])
    |> unique_constraint(:token)
  end

  @doc """
  Builds a changeset to restrict the token to read-only.
  """
  def restrict_changeset(auth_token) do
    auth_token
    |> change(is_read_only: true)
  end
end
