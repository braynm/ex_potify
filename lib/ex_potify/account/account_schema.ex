defmodule ExPotify.Account.AccountSchema do
  import Ecto.Changeset
  use Ecto.Schema

  @primary_key false

  schema "account" do
    field :username, :string
    field :email, :string
    field :refresh_token, :string
    field :access_token, :string

    timestamps()
  end

  def insert_or_update_account_changeset(data) do
    %__MODULE__{}
    |> cast(data, [:username, :email, :refresh_token, :access_token])
    |> validate_required([:username, :email, :refresh_token, :access_token])
    |> unique_constraint(:username, name: :account_pkey)
  end
end
