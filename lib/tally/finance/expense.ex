defmodule Tally.Finance.Expense do
  use Ecto.Schema
  import Ecto.Changeset

  schema "expenses" do
    field :amount, :decimal
    field :txn_date, :date
    field :memo, :string

    belongs_to :animal, Tally.Livestock.Animal
    belongs_to :category, Tally.Finance.Category
    belongs_to :vendor, Tally.Finance.Vendor

    has_many :attachments, Tally.Finance.Attachment, foreign_key: :expense_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(expense, attrs) do
    expense
    |> cast(attrs, [:animal_id, :category_id, :vendor_id, :amount, :txn_date, :memo])
    |> validate_required([:category_id, :amount, :txn_date])
    |> validate_number(:amount, greater_than: 0)
  end
end
