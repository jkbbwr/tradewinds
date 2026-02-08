defmodule Tradewinds.Companies.Director do
  use Ecto.Schema
  import Ecto.Changeset

  schema "director" do
    belongs_to :company, Tradewinds.Companies.Company
    belongs_to :player, Tradewinds.Accounts.Player
  end

  @doc false
  def changeset(director, attrs) do
    director
    |> cast(attrs, [:company_id, :player_id])
    |> validate_required([:company_id, :player_id])
    |> unique_constraint([:company_id, :player_id])
  end
end
