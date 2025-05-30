defmodule Tradewinds.Schema.Officer do
  use Tradewinds.Schema
  import Ecto.Changeset

  schema "officer" do
    belongs_to :company, Tradewinds.Schema.Company
    belongs_to :player, Tradewinds.Schema.Player

    timestamps()
  end

  @doc """
  Builds a changeset for the officer schema.
  """
  def changeset(officer, attrs) do
    officer
    |> cast(attrs, [:company_id, :player_id])
    |> validate_required([:company_id, :player_id])
    |> unique_constraint([:company_id, :player_id])
  end
end
