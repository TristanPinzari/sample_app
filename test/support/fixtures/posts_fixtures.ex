defmodule SampleApp.PostsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `SampleApp.Posts` context.
  """

  @doc """
  Generate a micropost.
  """
  def micropost_fixture(attrs \\ %{}) do
    {:ok, micropost} =
      attrs
      |> Enum.into(%{
        content: "some content"
      })
      |> SampleApp.Posts.create_micropost()

    micropost
  end
end
