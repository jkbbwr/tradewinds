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

  @doc """
  Changeset for updating a company agent's location.
  """
  def assign_to_port_changeset(company_agent, port_id) do
    company_agent
    |> cast(%{port_id: port_id, ship_id: nil}, [:port_id, :ship_id])
    |> validate_required([:port_id])
  end

  @doc """
  Changeset for assigning a company agent to a ship.
  """
  def assign_to_ship_changeset(company_agent, ship_id) do
    company_agent
    |> cast(%{ship_id: ship_id, port_id: nil}, [:ship_id, :port_id])
    |> validate_required([:ship_id])
  end
end
