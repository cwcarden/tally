defmodule Tally.Repo.Migrations.CreateFinanceAttachments do
  use Ecto.Migration

  def change do
    create table(:finance_attachments) do
      add :expense_id, references(:expenses, on_delete: :delete_all)
      add :income_id, references(:incomes, on_delete: :delete_all)
      add :file_path, :string, null: false
      add :note, :string
      add :mime_type, :string
      add :file_size, :integer
      add :sha256, :string

      timestamps(type: :utc_datetime)
    end

    create index(:finance_attachments, [:expense_id])
    create index(:finance_attachments, [:income_id])

    create constraint(:finance_attachments, :must_link_to_one,
      check: "(expense_id IS NOT NULL AND income_id IS NULL) OR (expense_id IS NULL AND income_id IS NOT NULL) OR (expense_id IS NULL AND income_id IS NULL)"
    )
  end
end
