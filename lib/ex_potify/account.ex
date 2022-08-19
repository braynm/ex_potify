defmodule ExPotify.Account do
  import Ecto.Query

  @doc """
  Inserts or update an account, this is used on register and register and login with Spotify
  """

  @spec insert_or_update_account(map()) ::
          %ExPotify.Account.AccountSchema{} | {:error, Ecto.Changeset.t()}
  def insert_or_update_account(data) do
    changeset = ExPotify.Account.AccountSchema.insert_or_update_account_changeset(data)

    if changeset.valid? == true do
      ExPotify.Repo.insert(
        changeset,
        conflict_target: :username,
        on_conflict: {:replace, [:username, :access_token, :refresh_token, :email]}
      )
    else
      {:error, changeset.errors}
    end
  end

  @doc """
  Fetch account by username
  """
  @spec fetch_account(binary()) :: map()
  def fetch_account(user_id) do
    query = from acc in ExPotify.Account.AccountSchema, where: acc.username == ^user_id

    ExPotify.Repo.one(query)
  end
end
