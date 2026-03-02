defmodule Tally.Repo.Migrations.CreateVendors do
  use Ecto.Migration

  def change do
    create table(:vendors) do
      add :name, :string, null: false
      add :tin, :string
      add :entity_type, :string
      add :address1, :string
      add :address2, :string
      add :city, :string
      add :state, :string
      add :zip, :string
      add :email, :string
      add :phone, :string
      add :is_attorney, :boolean, default: false
      add :is_medical, :boolean, default: false
      add :issue_1099, :boolean, default: false
      add :notes, :text

      timestamps(type: :utc_datetime)
    end

    create unique_index(:vendors, [:name])
  end
end
