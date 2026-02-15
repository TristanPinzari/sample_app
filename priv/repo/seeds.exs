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
