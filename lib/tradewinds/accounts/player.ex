defmodule Tradewinds.Accounts.Player do
  use Tradewinds.Schema

  schema "player" do
    field :name, :string
    field :email, :string
    field :password, :string, virtual: true
    field :password_hash, :string
    field :enabled, :boolean, default: false

    has_many :directorships, Tradewinds.Companies.Director

    many_to_many :companies, Tradewinds.Companies.Company,
      join_through: Tradewinds.Companies.Director

    timestamps()
  end

  defp hash_password(%{changes: %{password: password}} = changeset) do
    change(changeset, password_hash: Argon2.hash_pwd_salt(password))
  end

  defp hash_password(changeset), do: changeset

  def create_changeset(player, attrs) do
    player
    |> cast(attrs, [:name, :email, :password])
    |> validate_required([:name, :email, :password])
    |> validate_format(:email, ~r/^[^\s@]+@[^\s@]+\.[^\s@]+$/)
    |> validate_length(:password, min: 8)
    |> unique_constraint(:email)
    |> prepare_changes(&hash_password/1)
  end

  def enabled_changeset(player, enabled) do
    cast(player, %{enabled: enabled}, [:enabled])
  end
end
