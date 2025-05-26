defmodule Tradewinds.Schema.Season do
  use Tradewinds.Schema
  import Ecto.Changeset

  schema "season" do
    field :password, :string
    field :start_date, :utc_datetime

    timestamps()
  end

  @doc """
  Builds a changeset for the season schema.
  """
  def changeset(season, attrs) do
    season
    |> cast(attrs, [:password, :start_date])
    |> validate_required([:password, :start_date])
  end
end