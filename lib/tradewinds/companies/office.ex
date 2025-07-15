defmodule Tradewinds.Companies.Office do
  use Tradewinds.Schema
  import Ecto.Changeset

  alias Tradewinds.Companies.Company
  alias Tradewinds.World.Port

  schema "office" do
    belongs_to :company, Company, foreign_key: :company_id
    belongs_to :port, Port, foreign_key: :port_id

    timestamps()
  end

  def create_changeset(office, attrs) do
    office
    |> cast(attrs, [:company_id, :port_id])
    |> validate_required([:company_id, :port_id])
  end
end
