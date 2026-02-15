defmodule SampleApp.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  @valid_email_regex ~r/\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  @required_fields [:name, :email, :password, :password_confirmation]
  @identity_changeset_fields [:name, :email]

  schema "users" do
    field :name, :string
    field :email, :string
    field :password_hash, :string
    field :admin, :boolean, default: false
    field :activated, :boolean, default: false
    field :activated_at, :utc_datetime
    timestamps(type: :utc_datetime)
    field :password, :string, virtual: true
    field :password_confirmation, :string, virtual: true
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, @required_fields)
    |> validate_required(@required_fields, message: "This field is required.")
    |> validate_length(:name,
      min: 3,
      max: 30,
      message: "Must be between 3 to 30 characters"
    )
    |> validate_length(:email, max: 255)
    |> validate_length(:password,
      min: 10,
      max: 72,
      message: "Must be between 10 to 72 characters"
    )
    |> validate_format(:email, @valid_email_regex)
    |> validate_confirmation(:password, message: "Does not match password")
    |> update_change(:email, &String.downcase/1)
    |> unique_constraint(:email)
    |> put_password_hash()
  end

  def identity_changeset(user, attrs) do
    user
    |> cast(attrs, @identity_changeset_fields)
    |> validate_required(@identity_changeset_fields, message: "This field is required.")
    |> validate_length(:name,
      min: 3,
      max: 30,
      message: "Must be between 3 to 30 characters"
    )
    |> validate_length(:email, max: 255)
    |> validate_format(:email, @valid_email_regex)
    |> update_change(:email, &String.downcase/1)
    |> unique_constraint(:email)
  end

  defp put_password_hash(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: password}} ->
        if password do
          put_change(changeset, :password_hash, Pbkdf2.hash_pwd_salt(password))
        else
          changeset
        end

      _ ->
        changeset
    end
  end
end
