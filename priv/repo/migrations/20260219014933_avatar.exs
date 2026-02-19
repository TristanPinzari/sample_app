defmodule SampleApp.Repo.Migrations.Avatar do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :avatar, :string
    end
  end
end
