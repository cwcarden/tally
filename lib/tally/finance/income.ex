defmodule Tally.Finance.Income do
  use Ecto.Schema
  import Ecto.Changeset

  schema "incomes" do
    field :amount, :decimal
    field :txn_date, :date
    field :buyer, :string
    field :memo, :string

    belongs_to :animal, Tally.Livestock.Animal
    belongs_to :category, Tally.Finance.Category

    has_many :attachments, Tally.Finance.Attachment, foreign_key: :income_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(income, attrs) do
    income
    |> cast(attrs, [:animal_id, :category_id, :buyer, :amount, :txn_date, :memo])
    |> validate_required([:category_id, :amount, :txn_date])
    |> validate_number(:amount, greater_than: 0)
  end
end
