defmodule Tradewinds.Meta.Feedback do
  @moduledoc """
  Feedback schema.
  """
  use Tradewinds.Schema
  import Ecto.Changeset

  alias Tradewinds.Accounts.Player

  schema "feedback" do
    field :feedback, :string
    belongs_to :player, Player

    timestamps()
  end

  @doc """
  Changeset for creating and updating feedback.
  """
  def changeset(feedback, attrs) do
    feedback
    |> cast(attrs, [:feedback, :player_id])
    |> validate_required([:feedback])
  end
end
