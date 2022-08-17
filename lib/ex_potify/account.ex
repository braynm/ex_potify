defmodule ExPotify.Account do
  alias ExPotify.Repo

  @doc """
  Inserts or update an account, this is used on register and register and login with Spotify
  """

  @spec insert_or_update_account(map()) ::
          %ExPotify.Account.AccountSchema{} | {:error, Ecto.Changeset.t()}
  def insert_or_update_account(data) do
    changeset = ExPotify.Account.AccountSchema.insert_or_update_account_changeset(data)

    IO.inspect(String.length(data.refresh_token))

    if changeset.valid? == true do
      Repo.insert(
        changeset,
        conflict_target: :username,
        on_conflict: {:replace, [:username, :access_token, :refresh_token, :email]}
      )
    else
      {:error, changeset.errors}
    end
  end
end
