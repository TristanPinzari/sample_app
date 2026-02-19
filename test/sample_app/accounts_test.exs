defmodule SampleApp.AccountsTest do
  use SampleApp.DataCase

  alias SampleApp.Accounts

  describe "users" do
    alias SampleApp.Accounts.User

    import SampleApp.AccountsFixtures

    @invalid_attrs %{name: nil, email: nil}

    test "list_users/0 returns all users" do
      user = user_fixture()
      assert Accounts.list_users() == [user]
    end

    test "get_user!/1 returns the user with given id" do
      user = user_fixture()
      assert Accounts.get_user!(user.id) == user
    end

    test "create_user/1 with valid data creates a user" do
      valid_attrs = %{
        name: "some name",
        email: "some@gmail.com",
        password: "somepass123",
        password_confirmation: "somepass123"
      }

      assert {:ok, %User{} = user} = Accounts.create_user(valid_attrs)
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user(@invalid_attrs)
    end

    test "update_user/2 with valid data updates the user" do
      user = user_fixture()
      update_attrs = %{name: "some updated name", email: "some updated email"}

      assert {:ok, %User{} = user} = Accounts.update_user(user, update_attrs)
      assert user.name == "some updated name"
      assert user.email == "some updated email"
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_user(user, @invalid_attrs)
      assert user == Accounts.get_user!(user.id)
    end

    test "delete_user/1 deletes the user" do
      user = user_fixture()
      assert {:ok, %User{}} = Accounts.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_user!(user.id) end
    end

    test "change_user/1 returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = Accounts.change_user(user)
    end
  end

  describe "relationships" do
    alias SampleApp.Accounts.Relationship

    import SampleApp.AccountsFixtures

    @invalid_attrs %{follower_id: nil, followed_id: nil}

    test "list_relationships/0 returns all relationships" do
      relationship = relationship_fixture()
      assert Accounts.list_relationships() == [relationship]
    end

    test "get_relationship!/1 returns the relationship with given id" do
      relationship = relationship_fixture()
      assert Accounts.get_relationship!(relationship.id) == relationship
    end

    test "create_relationship/1 with valid data creates a relationship" do
      valid_attrs = %{follower_id: 42, followed_id: 42}

      assert {:ok, %Relationship{} = relationship} = Accounts.create_relationship(valid_attrs)
      assert relationship.follower_id == 42
      assert relationship.followed_id == 42
    end

    test "create_relationship/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_relationship(@invalid_attrs)
    end

    test "update_relationship/2 with valid data updates the relationship" do
      relationship = relationship_fixture()
      update_attrs = %{follower_id: 43, followed_id: 43}

      assert {:ok, %Relationship{} = relationship} =
               Accounts.update_relationship(relationship, update_attrs)

      assert relationship.follower_id == 43
      assert relationship.followed_id == 43
    end

    test "update_relationship/2 with invalid data returns error changeset" do
      relationship = relationship_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Accounts.update_relationship(relationship, @invalid_attrs)

      assert relationship == Accounts.get_relationship!(relationship.id)
    end

    test "delete_relationship/1 deletes the relationship" do
      relationship = relationship_fixture()
      assert {:ok, %Relationship{}} = Accounts.delete_relationship(relationship)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_relationship!(relationship.id) end
    end

    test "change_relationship/1 returns a relationship changeset" do
      relationship = relationship_fixture()
      assert %Ecto.Changeset{} = Accounts.change_relationship(relationship)
    end
  end
end
