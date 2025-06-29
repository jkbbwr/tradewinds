defmodule Tradewinds.Schema.Office do
  use Tradewinds.Schema
  import Ecto.Changeset
  import Ecto.Query

  alias Tradewinds.Repo

  @max_offices 1

  schema "office" do
    belongs_to :company, Tradewinds.Schema.Company, foreign_key: :company_id
    belongs_to :port, Tradewinds.Schema.Port, foreign_key: :port_id

    timestamps()
  end

  def create_changeset(office, attrs) do
    office
    |> cast(attrs, [:company_id, :port_id])
    |> validate_required([:company_id, :port_id])
    |> validate_max_offices()
  end

  defp validate_max_offices(changeset) do
    company_id = get_field(changeset, :company_id)

    office_count =
      Repo.one(from o in __MODULE__, where: o.company_id == ^company_id, select: count(o.id))

    if office_count >= @max_offices do
      add_error(changeset, :company_id, "can't have more than #{@max_offices} offices")
    else
      changeset
    end
  end
end
