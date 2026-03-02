defmodule Tally.Finance.Attachment do
  use Ecto.Schema
  import Ecto.Changeset

  schema "finance_attachments" do
    field :file_path, :string
    field :note, :string
    field :mime_type, :string
    field :file_size, :integer
    field :sha256, :string

    belongs_to :expense, Tally.Finance.Expense
    belongs_to :income, Tally.Finance.Income

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(attachment, attrs) do
    attachment
    |> cast(attrs, [:expense_id, :income_id, :file_path, :note, :mime_type, :file_size, :sha256])
    |> validate_required([:file_path])
    |> validate_exclusive_link()
  end

  defp validate_exclusive_link(changeset) do
    expense_id = get_field(changeset, :expense_id)
    income_id = get_field(changeset, :income_id)

    if expense_id && income_id do
      add_error(changeset, :base, "cannot link to both expense and income")
    else
      changeset
    end
  end
end
