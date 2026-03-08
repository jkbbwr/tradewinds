defmodule Tradewinds.Accounts.BannedIP do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "banned_ip" do
    field :ip_address, :string
    field :reason, :string

    timestamps()
  end

  @doc false
  def changeset(banned_ip, attrs) do
    banned_ip
    |> cast(attrs, [:ip_address, :reason])
    |> validate_required([:ip_address])
    |> unique_constraint(:ip_address)
  end
end
