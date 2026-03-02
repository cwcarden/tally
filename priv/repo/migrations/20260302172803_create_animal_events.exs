defmodule Tally.Repo.Migrations.CreateAnimalEvents do
  use Ecto.Migration

  def change do
    create table(:animal_events) do
      add :animal_id, references(:animals, on_delete: :restrict), null: false
      add :event_type_id, references(:event_types, on_delete: :restrict), null: false
      add :happened_on, :date, null: false
      add :description, :text

      timestamps(type: :utc_datetime)
    end

    create index(:animal_events, [:animal_id])
    create index(:animal_events, [:event_type_id])
    create index(:animal_events, [:happened_on])
  end
end
