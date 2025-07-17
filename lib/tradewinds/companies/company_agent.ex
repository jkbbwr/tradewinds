defmodule Tradewinds.Companies.CompanyAgent do
  @moduledoc """
  CompanyAgent schema.
  """
  use Tradewinds.Schema
  import Ecto.Changeset

  alias Tradewinds.Companies.Company
  alias Tradewinds.World.Port
  alias Tradewinds.Ships.Ship

  schema "company_agent" do
    belongs_to :company, Company
    belongs_to :port, Port
    belongs_to :ship, Ship

    timestamps()
  end

  @doc """
  Changeset for creating a new company agent.
  """
  def create_changeset(company_agent, attrs) do
    company_agent
    |> cast(attrs, [:company_id, :port_id])
    |> validate_required([:company_id, :port_id])
  end
end
