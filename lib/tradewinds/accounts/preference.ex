defmodule Tradewinds.Accounts.Preference do
  use Ecto.Schema
  import Ecto.Changeset

  alias Tradewinds.Accounts.Player

  schema "preference" do
    field :key, :string
    field :value, :string
    belongs_to :player, Player

    timestamps()
  end

  def changeset(preference, attrs) do
    preference
    |> cast(attrs, [:key, :value, :player_id])
    |> validate_required([:key, :value, :player_id])
  end
end
