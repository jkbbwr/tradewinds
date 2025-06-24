defmodule Tradewinds.Repo.PlayerRepo do
  import Ecto.Changeset
  alias Tradewinds.Schema.Player
  alias Tradewinds.Repo

  defp put_password_hash(%{valid?: true, changes: %{password: password}} = changeset) do
    change(changeset, password_hash: Argon2.hash_pwd_salt(password))
  end

  defp put_password_hash(changeset), do: changeset

  def register(name, email, password) do
    %Player{}
    |> cast(%{name: name, email: email, password: password}, [:name, :email, :password])
    |> validate_required([:name, :email])
    |> validate_required(:password, message: "can't be blank")
    |> validate_length(:password, min: 8)
    |> unique_constraint(:email)
    |> put_password_hash()
    |> Repo.insert()
  end

  def find_by_email(email) do
    Repo.fetch_by(Player, email: email)
  end
end
