import Ecto.Query, warn: false
alias SampleApp.Relationships

SampleApp.Repo.insert!(%SampleApp.Accounts.User{
  name: "Example User",
  email: "sample@gmail.com",
  password_hash: Pbkdf2.hash_pwd_salt("foobar"),
  admin: true,
  activated: true,
  activated_at: DateTime.truncate(DateTime.utc_now(), :second)
})

for n <- 1..99 do
  SampleApp.Repo.insert!(%SampleApp.Accounts.User{
    name: Faker.Person.name(),
    email: "example-#{n}@example.com",
    password_hash: Pbkdf2.hash_pwd_salt("foobar"),
    activated: true,
    activated_at: DateTime.truncate(DateTime.utc_now(), :second)
  })
end

users_40 =
  SampleApp.Repo.all(
    from u in SampleApp.Accounts.User,
      order_by: u.id,
      limit: 40
  )

first_user = hd(users_40)

following = Enum.slice(users_40, 2, 40)
followers = Enum.slice(users_40, 3, 40)

# The first user follows other users
for user <- following, do: Relationships.follow(first_user, user)

# Other users follow the first user
for user <- followers, do: Relationships.follow(user, first_user)
