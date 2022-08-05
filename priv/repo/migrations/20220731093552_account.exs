defmodule ExPotify.Repo.Migrations.Account do
  use Ecto.Migration

  def change do
    create table(:account, primary_key: false) do
      add :username, :string, primary_key: true
      add :email, :string
      add :refresh_token, :string
      add :access_token, :string
      timestamps()
    end
  end
end
