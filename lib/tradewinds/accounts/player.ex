defmodule Tradewinds.Accounts.Player do
  @derive {Inspect,
           only: [
             :id,
             :name,
             :email,
             :discord_id,
             :enabled,
             :directorships,
             :companies,
             :inserted_at,
             :updated_at
           ]}

  use Tradewinds.Schema

  schema "player" do
    field :name, :string
    field :email, :string
    field :discord_id, :string
    field :password, :string, virtual: true
    field :password_hash, :string
    field :enabled, :boolean, default: false

    has_many :directorships, Tradewinds.Companies.Director

    many_to_many :companies, Tradewinds.Companies.Company,
      join_through: Tradewinds.Companies.Director

    timestamps()
  end

  # Automatically hashes the virtual password field using Argon2 if it was changed.
  defp hash_password(%{changes: %{password: password}} = changeset) do
    change(changeset, password_hash: Argon2.hash_pwd_salt(password))
  end

  defp hash_password(changeset), do: changeset

  @doc """
  Builds a changeset for creating a new player, including password hashing.
  """
  def create_changeset(player, attrs) do
    player
    |> cast(attrs, [:name, :email, :password, :discord_id])
    |> validate_required([:name, :email, :password])
    |> validate_format(:email, ~r/^[^\s@]+@[^\s@]+\.[^\s@]+$/)
    |> validate_length(:password, min: 8)
    |> unique_constraint(:email)
    |> unique_constraint(:discord_id)
    |> prepare_changes(&hash_password/1)
  end

  @doc """
  Builds a changeset for updating the player's enabled status.
  """
  def enabled_changeset(player, enabled) do
    cast(player, %{enabled: enabled}, [:enabled])
  end
end
