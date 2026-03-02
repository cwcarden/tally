defmodule Tally.Finance.Category do
  use Ecto.Schema
  import Ecto.Changeset

  @kinds ~w(expense income)
  @report_forms ~w(none nec misc1 misc6 misc10)

  schema "categories" do
    field :name, :string
    field :kind, :string
    field :report_form, :string, default: "none"

    has_many :expenses, Tally.Finance.Expense
    has_many :incomes, Tally.Finance.Income

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(category, attrs) do
    category
    |> cast(attrs, [:name, :kind, :report_form])
    |> validate_required([:name, :kind])
    |> validate_inclusion(:kind, @kinds)
    |> validate_inclusion(:report_form, @report_forms)
    |> unique_constraint(:name)
  end

  def kinds, do: @kinds
  def report_forms, do: @report_forms
end
