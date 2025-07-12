defmodule Tradewinds.AccountsTest do
  use Tradewinds.DataCase

  alias Tradewinds.Accounts
  alias Tradewinds.Accounts.Player
  alias Tradewinds.Repo

  describe "create_player/3" do
    test "creates a player with valid attributes" do
      name = "Test User"
      email = "test_user@example.com"
      password = "securepassword"

      {:ok, player} = Accounts.create_player(name, email, password)

      assert %Tradewinds.Accounts.Player{
               id: _id,
               name: ^name,
               email: ^email,
               password_hash: _password_hash
             } = player

      # Verify the player is persisted in the database
      assert Repo.get_by!(Tradewinds.Accounts.Player, email: email)
    end

    test "does not create a player with short password" do
      name = "Short Password User"
      email = "short_password@example.com"
      # Less than 8 characters
      password = "short"

      {:error, changeset} = Accounts.create_player(name, email, password)

      assert %Ecto.Changeset{} = changeset
      assert changeset.valid? == false
      assert errors_on(changeset).password == ["should be at least 8 character(s)"]

      # Verify the player is not persisted
      assert Repo.get_by(Tradewinds.Accounts.Player, email: email) == nil
    end

    test "does not create a player with duplicate email" do
      name = "First User"
      email = "duplicate@example.com"
      password = "password1"

      {:ok, _} = Accounts.create_player(name, email, password)

      name2 = "Second User"
      password2 = "password2"

      {:error, changeset} = Accounts.create_player(name2, email, password2)

      assert %Ecto.Changeset{} = changeset
      assert changeset.valid? == false
      assert errors_on(changeset).email == ["has already been taken"]

      # Verify only one player with that email exists
      assert Repo.all(from p in Player, where: p.email == ^email) |> length == 1
    end
  end
end
