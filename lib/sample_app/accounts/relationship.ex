defmodule SampleApp.Accounts.Relationship do
  use Ecto.Schema
  import Ecto.Changeset
  alias SampleApp.Accounts.User

  schema "relationships" do
    field :follower_id, :integer
    field :followed_id, :integer

    belongs_to :followed, User, define_field: false
    belongs_to :follower, User, define_field: false
    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(relationship, attrs) do
    relationship
    |> cast(attrs, [:follower_id, :followed_id])
    |> validate_required([:follower_id, :followed_id])
    |> validate_different()
  end

  defp validate_different(changeset) do
    follower_id = get_field(changeset, :follower_id)
    followed_id = get_field(changeset, :followed_id)

    if follower_id == followed_id && follower_id != nil do
      add_error(changeset, :followed_id, "You cannot follow yourself")
    else
      changeset
    end
  end
end
