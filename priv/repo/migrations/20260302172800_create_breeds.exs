defmodule Tally.Repo.Migrations.CreateBreeds do
  use Ecto.Migration

  def change do
    create table(:breeds) do
      add :name, :string, null: false
      add :species, :string, null: false
      add :description, :text

      timestamps(type: :utc_datetime)
    end

    create unique_index(:breeds, [:name])
  end
end
