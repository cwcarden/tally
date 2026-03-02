defmodule Tally.Repo.Migrations.CreateIncomes do
  use Ecto.Migration

  def change do
    create table(:incomes) do
      add :animal_id, references(:animals, on_delete: :nilify_all)
      add :category_id, references(:categories, on_delete: :restrict), null: false
      add :buyer, :string
      add :amount, :decimal, precision: 12, scale: 2, null: false
      add :txn_date, :date, null: false
      add :memo, :string

      timestamps(type: :utc_datetime)
    end

    create index(:incomes, [:animal_id])
    create index(:incomes, [:category_id])
    create index(:incomes, [:txn_date])
  end
end
