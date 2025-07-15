defmodule Tradewinds.Meta.BugReport do
  use Tradewinds.Schema
  import Ecto.Changeset

  alias Tradewinds.Accounts.Player

  schema "bug_report" do
    field :report, :string
    belongs_to :player, Player

    timestamps()
  end

  def changeset(bug_report, attrs) do
    bug_report
    |> cast(attrs, [:report, :player_id])
    |> validate_required([:report])
  end
end
