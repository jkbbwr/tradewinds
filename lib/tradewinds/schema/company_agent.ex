
defmodule Tradewinds.Schema.CompanyAgent do
  use Ecto.Schema
  import Ecto.Changeset

  alias Tradewinds.Schema.Company
  alias Tradewinds.Schema.Port
  alias Tradewinds.Schema.Ship

  @primary_key false
  schema "company_agent" do
    belongs_to :company, Company
    belongs_to :port, Port
    belongs_to :ship, Ship

    timestamps()
  end

  def changeset(company_agent, attrs) do
    company_agent
    |> cast(attrs, [:company_id, :port_id, :ship_id])
    |> validate_required([:company_id])
    |> validate_port_or_ship()
  end

  defp validate_port_or_ship(changeset) do
    port_id = get_field(changeset, :port_id)
    ship_id = get_field(changeset, :ship_id)

    if is_nil(port_id) and is_nil(ship_id) do
      add_error(changeset, :port_id, "must have a port or ship")
    else
      changeset
    end
  end
end
