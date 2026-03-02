defmodule Tally.Repo.Migrations.CreateAnimals do
  use Ecto.Migration

  def change do
    create table(:animals) do
      add :tag, :string, null: false
      add :name, :string
      add :kind, :string, null: false
      add :sex, :string, null: false
      add :dob, :date
      add :notes, :text
      add :status, :string, null: false, default: "active"
      add :status_date, :date
      add :status_note, :string
      add :owned, :boolean, null: false, default: true
      add :thumbnail_path, :string
      add :breed_id, references(:breeds, on_delete: :nilify_all)
      add :sire_id, references(:animals, on_delete: :nilify_all)
      add :dam_id, references(:animals, on_delete: :nilify_all)

      timestamps(type: :utc_datetime)
    end

    create index(:animals, [:tag])
    create index(:animals, [:kind])
    create index(:animals, [:status])
    create index(:animals, [:breed_id])
    create index(:animals, [:sire_id])
    create index(:animals, [:dam_id])
  end
end
