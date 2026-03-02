defmodule Tally.Repo.Migrations.CreateExpenses do
  use Ecto.Migration

  def change do
    create table(:expenses) do
      add :animal_id, references(:animals, on_delete: :nilify_all)
      add :category_id, references(:categories, on_delete: :restrict), null: false
      add :vendor_id, references(:vendors, on_delete: :nilify_all)
      add :amount, :decimal, precision: 12, scale: 2, null: false
      add :txn_date, :date, null: false
      add :memo, :string

      timestamps(type: :utc_datetime)
    end

    create index(:expenses, [:animal_id])
    create index(:expenses, [:category_id])
    create index(:expenses, [:vendor_id])
    create index(:expenses, [:txn_date])
  end
end
