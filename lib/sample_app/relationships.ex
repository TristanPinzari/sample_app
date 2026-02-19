defmodule SampleApp.Relationships do
  import Ecto.Query, warn: false
  alias SampleApp.Repo
  alias SampleApp.Accounts.Relationship
  alias SampleApp.Posts.Micropost

  def create_relationship(attrs, user) do
    user
    |> Ecto.build_assoc(:active_relationships)
    |> Relationship.changeset(attrs)
    |> Repo.insert()
  end

  def follow(follower, followed_id) do
    create_relationship(%{followed_id: followed_id}, follower)
  end

  def unfollow(follower_id, followed_id) do
    found_following =
      Repo.one(
        from r in Relationship,
          where: r.follower_id == ^follower_id and r.followed_id == ^followed_id
      )

    case found_following do
      nil ->
        nil

      _ ->
        Repo.delete(found_following)
    end
  end

  def following?(potential_follower, potential_followed) do
    Repo.one(
      from r in Relationship,
        where:
          r.follower_id == ^potential_follower.id and
            r.followed_id == ^potential_followed.id
    ) != nil
  end

  def follower?(potential_followed, potential_follower) do
    if potential_follower.id == potential_followed.id do
      false
    else
      following?(potential_follower, potential_followed)
    end
  end

  def following_count(user) do
    Relationship
    |> where(follower_id: ^user.id)
    |> Repo.aggregate(:count, :id)
  end

  def follower_count(user) do
    Relationship
    |> where(followed_id: ^user.id)
    |> Repo.aggregate(:count, :id)
  end

  def follower_query(user) do
    from(r in Relationship,
      where: r.follower_id == ^user.id
    )
  end

  def microposts_for_feed_query(user) do
    user_microposts =
      from(mp in Micropost,
        where: mp.user_id == ^user.id
      )

    microposts_query =
      from(m in Micropost,
        join: f in subquery(follower_query(user)),
        on: m.user_id == f.followed_id,
        union_all: ^user_microposts
      )

    # Order the queries to have the latest microposts
    # at the very top
    from(q in subquery(microposts_query),
      order_by: [desc: :inserted_at]
    )
  end

  def microposts_for_feed(user) do
    microposts_for_feed_query(user)
    |> Repo.all()
    |> Repo.preload([:user])
  end
end
