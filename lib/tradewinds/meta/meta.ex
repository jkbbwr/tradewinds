defmodule Tradewinds.Meta do
  alias Tradewinds.Repo
  alias Tradewinds.Meta.BugReport
  alias Tradewinds.Meta.Feedback

  def create_bug_report(player, report) do
    %BugReport{}
    |> BugReport.changeset(%{player_id: player.id, report: report})
    |> Repo.insert()
  end

  def create_feedback(player, feedback) do
    %Feedback{}
    |> Feedback.changeset(%{player_id: player.id, feedback: feedback})
    |> Repo.insert()
  end
end
