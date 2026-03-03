defmodule Tradewinds.Clock.Season do
  use Tradewinds.Schema

  schema "season" do
    field :start_date, :utc_datetime_usec
    field :end_date, :utc_datetime_usec
    field :active, :boolean, default: false
    field :tick_duration_seconds, :integer, default: 24

    timestamps()
  end

  @doc """
  Builds a changeset for a season, enforcing tick duration boundaries 
  and unique active constraints.
  """
  def changeset(season, attrs) do
    season
    |> cast(attrs, [:start_date, :end_date, :active, :tick_duration_seconds])
    |> validate_required([:start_date, :end_date, :tick_duration_seconds])
    |> validate_number(:tick_duration_seconds, greater_than: 0)
    |> check_constraint(:active, name: :active_season_must_be_unique)
  end
end
