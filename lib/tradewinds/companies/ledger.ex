defmodule Tradewinds.Companies.Ledger do
  use Tradewinds.Schema

  schema "company_ledger" do
    field :tick, :integer
    field :amount, :integer
    field :reason, :string
    field :reference_type, :string
    field :reference_id, :binary_id
    field :idempotency_key, :string
    field :meta, :map

    belongs_to :company, Tradewinds.Companies.Company

    timestamps()
  end

  @doc false
  def create_changeset(ledger, attrs) do
    ledger
    |> cast(attrs, [:company_id, :tick, :amount, :reason, :reference_type, :reference_id, :idempotency_key, :meta])
    |> validate_required([:company_id, :tick, :amount, :reason, :reference_type, :reference_id, :idempotency_key])
    |> validate_number(:amount, not_equal_to: 0)
    |> validate_number(:tick, greater_than_or_equal_to: 0)
    |> unique_constraint(:idempotency_key)
  end
end
