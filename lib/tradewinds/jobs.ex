defmodule Tradewinds.Jobs do
  @moduledoc """
  Utilities for managing and kickstarting background jobs.
  """

  import Ecto.Query
  alias Tradewinds.Repo
  alias Tradewinds.Trade.{Trader, TraderSimulationJob, TraderMonthlyJob}
  alias Tradewinds.Companies.{Company, UpkeepJob}
  alias Tradewinds.Shipyards.{Shipyard, ProductionJob}

  @doc """
  Enqueues the first iteration of all recurring background jobs for all entities.
  Safe to run multiple times due to Oban's uniqueness constraints.
  """
  def kickstart do
    Repo.transact(fn ->
      kickstart_traders()
      kickstart_companies()
      kickstart_shipyards()
      {:ok, :kickstarted}
    end)
  end

  @doc """
  Returns a map of background job counts by worker type.
  """
  def get_job_counts do
    query =
      from j in "oban_jobs",
        where: j.state in ["available", "scheduled", "retryable"],
        group_by: j.worker,
        select: {j.worker, count(j.id)}

    Repo.all(query)
    |> Enum.into(%{}, fn {worker, count} ->
      name = worker |> String.split(".") |> List.last()
      {name, count}
    end)
  end

  defp kickstart_traders do
    traders = Repo.all(Trader)

    Enum.each(traders, fn trader ->
      # Daily Simulation
      %{trader_id: trader.id}
      |> TraderSimulationJob.new()
      |> Oban.insert!()

      # Monthly Stance Reset
      %{trader_id: trader.id}
      |> TraderMonthlyJob.new()
      |> Oban.insert!()
    end)
  end

  defp kickstart_companies do
    companies = Repo.all(Company)

    Enum.each(companies, fn company ->
      # Monthly Upkeep
      %{company_id: company.id}
      |> UpkeepJob.new()
      |> Oban.insert!()
    end)
  end

  defp kickstart_shipyards do
    shipyards = Repo.all(Shipyard)

    Enum.each(shipyards, fn shipyard ->
      # Weekly Production
      %{shipyard_id: shipyard.id}
      |> ProductionJob.new()
      |> Oban.insert!()
    end)
  end
end
