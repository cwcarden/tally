defmodule Tally.Livestock.Animal do
  use Ecto.Schema
  import Ecto.Changeset

  @kinds ~w(horse cattle dog)
  @statuses ~w(active sold deceased retired)
  @sexes ~w(stallion mare gelding bull cow steer heifer male female)

  schema "animals" do
    field :tag, :string
    field :name, :string
    field :kind, :string
    field :sex, :string
    field :dob, :date
    field :notes, :string
    field :status, :string, default: "active"
    field :status_date, :date
    field :status_note, :string
    field :owned, :boolean, default: true
    field :thumbnail_path, :string

    belongs_to :breed, Tally.Livestock.Breed
    belongs_to :sire, Tally.Livestock.Animal
    belongs_to :dam, Tally.Livestock.Animal

    has_many :offspring_as_sire, Tally.Livestock.Animal, foreign_key: :sire_id
    has_many :offspring_as_dam, Tally.Livestock.Animal, foreign_key: :dam_id
    has_many :animal_events, Tally.Events.AnimalEvent
    has_many :animal_documents, Tally.Documents.AnimalDocument
    has_many :expenses, Tally.Finance.Expense
    has_many :incomes, Tally.Finance.Income

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(animal, attrs) do
    animal
    |> cast(attrs, [
      :tag, :name, :kind, :sex, :dob, :notes, :status,
      :status_date, :status_note, :owned, :thumbnail_path,
      :breed_id, :sire_id, :dam_id
    ])
    |> validate_required([:tag, :kind, :sex, :status])
    |> validate_inclusion(:kind, @kinds)
    |> validate_inclusion(:status, @statuses)
    |> validate_inclusion(:sex, @sexes)
    |> validate_no_self_reference(:sire_id)
    |> validate_no_self_reference(:dam_id)
  end

  def kinds, do: @kinds
  def statuses, do: @statuses
  def sexes, do: @sexes

  defp validate_no_self_reference(changeset, field) do
    id = changeset.data.id
    value = get_change(changeset, field)
    if id && value && id == value do
      add_error(changeset, field, "cannot reference itself")
    else
      changeset
    end
  end
end
