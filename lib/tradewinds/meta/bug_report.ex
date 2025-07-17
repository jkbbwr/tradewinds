defmodule Tradewinds.Meta.BugReport do
  @moduledoc """
  BugReport schema.
  """
  use Tradewinds.Schema
  import Ecto.Changeset

  alias Tradewinds.Accounts.Player

  schema "bug_report" do
    field :report, :string
    belongs_to :player, Player

    timestamps()
  end

  @doc """
  Changeset for creating and updating bug reports.
  """
  def changeset(bug_report, attrs) do
    bug_report
    |> cast(attrs, [:report, :player_id])
    |> validate_required([:report])
  end
end
