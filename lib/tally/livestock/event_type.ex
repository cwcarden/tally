defmodule Tally.Livestock.EventType do
  use Ecto.Schema
  import Ecto.Changeset

  schema "event_types" do
    field :name, :string
    field :description, :string

    has_many :animal_events, Tally.Events.AnimalEvent

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(event_type, attrs) do
    event_type
    |> cast(attrs, [:name, :description])
    |> validate_required([:name])
    |> validate_length(:name, min: 1, max: 100)
    |> unique_constraint(:name)
  end
end
