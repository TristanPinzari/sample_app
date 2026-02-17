defmodule SampleApp.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias SampleApp.Repo
  alias SampleApp.Accounts.User
  alias SampleApp.{Mailer, Email}
  alias SampleApp.Posts.Micropost

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  def list_users(params \\ %{}, activated_users_only \\ true) do
    page = String.to_integer(params["page"] || "1")
    per_page = 10
    offset = (page - 1) * per_page

    query = User

    query =
      if activated_users_only do
        where(query, [u], u.activated == true)
      else
        query
      end

    query
    |> order_by(asc: :id)
    |> limit(^per_page)
    |> offset(^offset)
    |> Repo.all()
  end

  def count_users(activated_users_only \\ true) do
    query = User

    query =
      if activated_users_only do
        where(query, [u], u.activated == true)
      else
        query
      end

    Repo.aggregate(query, :count, :id)
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: Repo.get!(User, id)
  def get_user(id), do: Repo.get(User, id)
  def get_user_by(params), do: Repo.get_by(User, params)

  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(attrs) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user_identity(%User{} = user, attrs) do
    password = attrs["password"] || attrs[:password]

    if Pbkdf2.verify_pass(password, user.password_hash) do
      user
      |> User.identity_changeset(attrs)
      |> Repo.update()
    else
      user
      |> User.identity_changeset(attrs)
      |> Ecto.Changeset.add_error(:password, "Incorrect password")
      |> Ecto.Changeset.apply_action(:update)
    end
  end

  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a user.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user(%User{} = user, attrs \\ %{}) do
    User.changeset(user, attrs)
  end

  def authenticate_by_email_and_pass(email, given_pass) do
    user = Repo.get_by(User, email: email)

    cond do
      user && Pbkdf2.verify_pass(given_pass, user.password_hash) ->
        {:ok, user}

      user ->
        {:error, :unauthorized}

      true ->
        Pbkdf2.no_user_verify()
        {:error, :not_found}
    end
  end

  def activate_user(%User{activated: false} = user) do
    user
    |> User.token_changeset(%{
      activated: true,
      activated_at: DateTime.truncate(DateTime.utc_now(), :second)
    })
    |> Repo.update()
  end

  def activate_user(%User{activated: true}) do
    {:error, :already_activated}
  end

  def send_user_activation_email(%User{activated: false} = user) do
    activation_token = SampleApp.Token.gen_activation_token(user)

    user
    |> Email.account_activation_email(activation_token)
    |> Mailer.deliver()
  end

  def send_user_password_reset_email(%User{} = user) do
    reset_token = SampleApp.Token.gen_reset_token(user)

    user
    |> Email.password_reset_email(reset_token)
    |> Mailer.deliver()
  end

  def password_change_user(%User{} = user) do
    User.password_changeset(user, %{})
  end

  def update_user_password(%User{} = user, attrs) do
    user
    |> User.password_changeset(attrs)
    |> Repo.update()
  end

  def preload_microposts_recent_as_top(user) do
    Repo.preload(user, microposts: Micropost |> order_by(desc: :id))
  end

  def preload_microposts(user) do
    Repo.preload(user, :microposts)
  end
end
