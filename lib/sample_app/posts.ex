defmodule SampleApp.Posts do
  @moduledoc """
  The Posts context.
  """

  import Ecto.Query, warn: false
  require Logger
  alias SampleApp.Repo

  alias SampleApp.Posts.Micropost

  @doc """
  Returns the list of microposts.

  ## Examples

      iex> list_microposts()
      [%Micropost{}, ...]

  """
  def list_microposts(params \\ %{}) do
    page = String.to_integer(params["page"] || "1")
    per_page = 10
    offset = (page - 1) * per_page

    Micropost
    |> order_by(desc: :id)
    |> limit(^per_page)
    |> offset(^offset)
    |> Repo.all()
  end

  def count_microposts() do
    Repo.aggregate(Micropost, :count, :id)
  end

  def count_user_microposts(user_id) do
    Micropost
    |> where([m], m.user_id == ^user_id)
    |> Repo.aggregate(:count, :id)
  end

  @doc """
  Gets a single micropost.

  Raises `Ecto.NoResultsError` if the Micropost does not exist.

  ## Examples

      iex> get_micropost!(123)
      %Micropost{}

      iex> get_micropost!(456)
      ** (Ecto.NoResultsError)

  """
  def get_micropost!(id), do: Repo.get!(Micropost, id)

  @doc """
  Creates a micropost.

  ## Examples

      iex> create_micropost(%{field: value})
      {:ok, %Micropost{}}

      iex> create_micropost(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_micropost(attrs, user) do
    struct_with_user = Ecto.build_assoc(user, :microposts)
    base_changeset = Micropost.changeset(struct_with_user, attrs)

    micropost_transaction =
      Ecto.Multi.new()
      |> Ecto.Multi.insert(:micropost, base_changeset)
      |> Ecto.Multi.update(:micropost_with_image, fn %{micropost: post} ->
        Micropost.image_changeset(post, attrs)
      end)
      |> Repo.transaction()

    case micropost_transaction do
      {:ok, result} ->
        {:ok, result.micropost}

      {:error, :micropost, changeset, _changes} ->
        {:error, changeset}

      {:error, :micropost_with_image, changeset, _changes} ->
        {:error, changeset}
    end
  end

  @doc """
  Updates a micropost.

  ## Examples

      iex> update_micropost(micropost, %{field: new_value})
      {:ok, %Micropost{}}

      iex> update_micropost(micropost, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_micropost(%Micropost{} = micropost, attrs) do
    micropost
    |> Micropost.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a micropost.

  ## Examples

      iex> delete_micropost(micropost)
      {:ok, %Micropost{}}

      iex> delete_micropost(micropost)
      {:error, %Ecto.Changeset{}}

  """
  def delete_micropost(%{micropost_id: micropost_id_str, user_id: user_id}) do
    Repo.transaction(fn ->
      micropost_id = String.to_integer(micropost_id_str)

      found_micropost =
        Repo.one(
          from m in Micropost,
            where: m.user_id == ^user_id and m.id == ^micropost_id
        )

      case found_micropost do
        nil ->
          Repo.rollback(:not_found)

        micropost ->
          case Repo.delete(micropost) do
            {:ok, deleted_struct} ->
              if deleted_struct.image do
                try do
                  SampleApp.Image.delete({deleted_struct.image, deleted_struct})
                rescue
                  e ->
                    Repo.rollback(:error)

                    Logger.error(
                      "Failed to delete S3 file for post #{deleted_struct.id}: #{inspect(e)}"
                    )
                end
              end

              deleted_struct

            {:error, changeset} ->
              Repo.rollback(changeset)
          end
      end
    end)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking micropost changes.

  ## Examples

      iex> change_micropost(micropost)
      %Ecto.Changeset{data: %Micropost{}}

  """
  def change_micropost(%Micropost{} = micropost, attrs \\ %{}) do
    Micropost.changeset(micropost, attrs)
  end
end
