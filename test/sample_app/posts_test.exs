defmodule SampleApp.PostsTest do
  use SampleApp.DataCase

  alias SampleApp.Posts

  describe "microposts" do
    alias SampleApp.Posts.Micropost

    import SampleApp.PostsFixtures

    @invalid_attrs %{content: nil}

    test "list_microposts/0 returns all microposts" do
      micropost = micropost_fixture()
      assert Posts.list_microposts() == [micropost]
    end

    test "get_micropost!/1 returns the micropost with given id" do
      micropost = micropost_fixture()
      assert Posts.get_micropost!(micropost.id) == micropost
    end

    test "create_micropost/1 with valid data creates a micropost" do
      valid_attrs = %{content: "some content"}

      assert {:ok, %Micropost{} = micropost} = Posts.create_micropost(valid_attrs)
      assert micropost.content == "some content"
    end

    test "create_micropost/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Posts.create_micropost(@invalid_attrs)
    end

    test "update_micropost/2 with valid data updates the micropost" do
      micropost = micropost_fixture()
      update_attrs = %{content: "some updated content"}

      assert {:ok, %Micropost{} = micropost} = Posts.update_micropost(micropost, update_attrs)
      assert micropost.content == "some updated content"
    end

    test "update_micropost/2 with invalid data returns error changeset" do
      micropost = micropost_fixture()
      assert {:error, %Ecto.Changeset{}} = Posts.update_micropost(micropost, @invalid_attrs)
      assert micropost == Posts.get_micropost!(micropost.id)
    end

    test "delete_micropost/1 deletes the micropost" do
      micropost = micropost_fixture()
      assert {:ok, %Micropost{}} = Posts.delete_micropost(micropost)
      assert_raise Ecto.NoResultsError, fn -> Posts.get_micropost!(micropost.id) end
    end

    test "change_micropost/1 returns a micropost changeset" do
      micropost = micropost_fixture()
      assert %Ecto.Changeset{} = Posts.change_micropost(micropost)
    end
  end
end
