defmodule SampleApp.Token do
  alias SampleApp.Accounts.User
  @remember_salt "remember-use-salt"
  @activation_salt "activation-user-salt"

  def gen_remember_token(%User{id: user_id}) do
    Phoenix.Token.sign(SampleAppWeb.Endpoint, @remember_salt, user_id)
  end

  def verify_remember_token(token) do
    Phoenix.Token.verify(SampleAppWeb.Endpoint, @remember_salt, token, max_age: :infinity)
  end

  def gen_activation_token(%User{id: user_id}) do
    Phoenix.Token.sign(SampleAppWeb.Endpoint, @activation_salt, user_id)
  end

  def verify_activation_token(token) do
    max_age = 86_400
    Phoenix.Token.verify(SampleAppWeb.Endpoint, @activation_salt, token, max_age: max_age)
  end
end
