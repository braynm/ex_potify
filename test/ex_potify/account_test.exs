defmodule ExPotify.AccountTest do
  use ExPotify.DataCase, async: true

  @tag :account
  describe "Account.insert_or_update_account/1" do
    test "insert account with missing email" do
      data = %{
        username: "hallo",
        # email: "",
        refresh_token: "test",
        access_token: "test"
      }

      errors = ExPotify.Account.insert_or_update_account(data)
      assert errors == {:error, [email: {"can't be blank", [validation: :required]}]}
    end

    @tag :account
    test "insert account with valid params" do
      data = %{
        username: "hallo",
        email: "test",
        refresh_token: "test",
        access_token: "test"
      }

      account = ExPotify.Account.insert_or_update_account(data)
      assert {:ok, _} = account
    end

    @tag :account
    test "upsert account with existing username" do
      data = %{
        username: "hallo",
        email: "old email",
        refresh_token: "test",
        access_token: "test"
      }

      ExPotify.Account.insert_or_update_account(data)

      {:ok, changeset} =
        ExPotify.Account.insert_or_update_account(
          Map.merge(data, %{
            email: "updated email"
          })
        )

      assert changeset.email == "updated email"
    end
  end
end
