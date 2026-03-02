defmodule Tally.Events.AnimalEvent do
  use Ecto.Schema
  import Ecto.Changeset

  schema "animal_events" do
    field :happened_on, :date
    field :description, :string

    belongs_to :animal, Tally.Livestock.Animal
    belongs_to :event_type, Tally.Livestock.EventType

    has_many :animal_documents, Tally.Documents.AnimalDocument,
      foreign_key: :animal_event_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(animal_event, attrs) do
    animal_event
    |> cast(attrs, [:animal_id, :event_type_id, :happened_on, :description])
    |> validate_required([:animal_id, :event_type_id, :happened_on])
  end
end
