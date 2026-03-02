defmodule Tally.Finance.Vendor do
  use Ecto.Schema
  import Ecto.Changeset

  @entity_types ~w(individual sole_prop llc partnership corporation s_corp)

  schema "vendors" do
    field :name, :string
    field :tin, :string
    field :entity_type, :string
    field :address1, :string
    field :address2, :string
    field :city, :string
    field :state, :string
    field :zip, :string
    field :email, :string
    field :phone, :string
    field :is_attorney, :boolean, default: false
    field :is_medical, :boolean, default: false
    field :issue_1099, :boolean, default: false
    field :notes, :string

    has_many :expenses, Tally.Finance.Expense

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(vendor, attrs) do
    vendor
    |> cast(attrs, [
      :name, :tin, :entity_type, :address1, :address2, :city, :state, :zip,
      :email, :phone, :is_attorney, :is_medical, :issue_1099, :notes
    ])
    |> validate_required([:name])
    |> validate_length(:name, min: 1, max: 200)
    |> unique_constraint(:name)
  end

  def entity_types, do: @entity_types
end
