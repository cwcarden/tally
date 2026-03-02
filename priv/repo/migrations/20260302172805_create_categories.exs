defmodule Tally.Repo.Migrations.CreateCategories do
  use Ecto.Migration

  def change do
    create table(:categories) do
      add :name, :string, null: false
      add :kind, :string, null: false
      add :report_form, :string, null: false, default: "none"

      timestamps(type: :utc_datetime)
    end

    create unique_index(:categories, [:name])
  end
end
