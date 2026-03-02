defmodule Tally.Repo.Migrations.CreateEventTypes do
  use Ecto.Migration

  def change do
    create table(:event_types) do
      add :name, :string, null: false
      add :description, :text

      timestamps(type: :utc_datetime)
    end

    create unique_index(:event_types, [:name])
  end
end
