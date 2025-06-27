defmodule Tradewinds.Schema.Office do
  use Tradewinds.Schema
  import Ecto.Changeset
  import Ecto.Query

  alias Tradewinds.Repo

  schema "offices" do
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
      Repo.aggregate(from(o in __MODULE__, where: o.company_id == ^company_id), :count, :id)

    if office_count >= 3 do
      add_error(changeset, :company_id, "can't have more than 3 offices")
    else
      changeset
    end
  end
end
