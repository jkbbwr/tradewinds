defmodule Tradewinds.Schema.Orderbook do
  use Tradewinds.Schema
  import Ecto.Changeset

  alias Tradewinds.Schema.Company
  alias Tradewinds.Schema.Item
  alias Tradewinds.Schema.Port

  schema "orderbook" do
    field :order, :string
    field :amount, :integer
    field :cost, :integer
    belongs_to :port, Port
    belongs_to :company, Company
    belongs_to :item, Item

    timestamps()
  end

  def changeset(orderbook, attrs) do
    orderbook
    |> cast(attrs, [:order, :amount, :cost, :port_id, :company_id, :item_id])
    |> validate_required([:order, :amount, :cost, :port_id, :company_id, :item_id])
  end
end
