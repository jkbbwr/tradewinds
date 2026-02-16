defmodule Tradewinds.Companies.Director do
  use Tradewinds.Schema

  schema "director" do
    belongs_to :company, Tradewinds.Companies.Company
    belongs_to :player, Tradewinds.Accounts.Player
  end

  @doc false
  def create_changeset(director, attrs) do
    director
    |> cast(attrs, [:company_id, :player_id])
    |> validate_required([:company_id, :player_id])
    |> unique_constraint([:company_id, :player_id])
  end
end
