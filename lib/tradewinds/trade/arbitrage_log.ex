defmodule Tradewinds.Trade.ArbitrageLog do
  use Tradewinds.Schema

  schema "arbitrage_log" do
    field :margin, :float
    field :action, :string
    field :details, :map

    belongs_to :good, Tradewinds.World.Good
    belongs_to :cheap_port, Tradewinds.World.Port
    belongs_to :expensive_port, Tradewinds.World.Port

    timestamps()
  end

  def changeset(log, attrs) do
    log
    |> cast(attrs, [
      :good_id,
      :cheap_port_id,
      :expensive_port_id,
      :margin,
      :action,
      :details
    ])
    |> validate_required([
      :good_id,
      :cheap_port_id,
      :expensive_port_id,
      :margin,
      :action,
      :details
    ])
  end
end
