defmodule Tradewinds.Trading.Orderbook do
  @moduledoc """
  Orderbook schema.
  """
  use Tradewinds.Schema
  import Ecto.Changeset

  alias Tradewinds.Companies.Company
  alias Tradewinds.World.Item
  alias Tradewinds.World.Port

  schema "orderbook" do
    field :order, :string
    field :amount, :integer
    field :cost, :integer
    belongs_to :port, Port
    belongs_to :company, Company
    belongs_to :item, Item

    timestamps()
  end

  @doc """
  Changeset for creating and updating orderbook entries.
  """
  def changeset(orderbook, attrs) do
    orderbook
    |> cast(attrs, [:order, :amount, :cost, :port_id, :company_id, :item_id])
    |> validate_required([:order, :amount, :cost, :port_id, :company_id, :item_id])
  end
end
