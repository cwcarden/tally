defmodule Tally.Repo.Migrations.CreateAnimalDocuments do
  use Ecto.Migration

  def change do
    create table(:animal_documents) do
      add :animal_id, references(:animals, on_delete: :restrict), null: false
      add :animal_event_id, references(:animal_events, on_delete: :nilify_all)
      add :name, :string, null: false
      add :kind, :string
      add :file_path, :string, null: false
      add :mime_type, :string
      add :file_size, :integer
      add :sha256, :string

      timestamps(type: :utc_datetime)
    end

    create index(:animal_documents, [:animal_id])
    create index(:animal_documents, [:animal_event_id])
  end
end
