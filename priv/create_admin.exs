alias Tally.{Repo, Accounts}
alias Tally.Accounts.User

email = "admin@gimelranch.com"
password = "password"

# Remove any existing users with either email
for e <- [email, "admin@tally.local"] do
  case Repo.get_by(User, email: e) do
    nil -> :ok
    user -> Repo.delete!(user)
  end
end

# Build changeset: email + password + confirmed
changeset =
  %User{}
  |> User.email_changeset(%{email: email})
  |> User.password_changeset(%{password: password})
  |> Ecto.Changeset.put_change(:confirmed_at, DateTime.utc_now() |> DateTime.truncate(:second))

case Repo.insert(changeset) do
  {:ok, user} ->
    IO.puts("✓ Admin created: #{user.email} / #{password}")
  {:error, cs} ->
    IO.inspect(cs.errors, label: "Error")
end
