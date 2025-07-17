defmodule Tradewinds.Meta do
  @moduledoc """
  The Meta context, for feedback and bug reports.
  """
  alias Tradewinds.Repo
  alias Tradewinds.Meta.BugReport
  alias Tradewinds.Meta.Feedback

  @doc """
  Creates a new bug report.
  """
  def create_bug_report(player, report) do
    %BugReport{}
    |> BugReport.changeset(%{player_id: player.id, report: report})
    |> Repo.insert()
  end

  @doc """
  Creates new feedback.
  """
  def create_feedback(player, feedback) do
    %Feedback{}
    |> Feedback.changeset(%{player_id: player.id, feedback: feedback})
    |> Repo.insert()
  end
end
