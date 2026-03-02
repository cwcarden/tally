defmodule Tally.Documents.AnimalDocument do
  use Ecto.Schema
  import Ecto.Changeset

  schema "animal_documents" do
    field :name, :string
    field :kind, :string
    field :file_path, :string
    field :mime_type, :string
    field :file_size, :integer
    field :sha256, :string

    belongs_to :animal, Tally.Livestock.Animal
    belongs_to :animal_event, Tally.Events.AnimalEvent

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(doc, attrs) do
    doc
    |> cast(attrs, [:animal_id, :animal_event_id, :name, :kind, :file_path, :mime_type, :file_size, :sha256])
    |> validate_required([:animal_id, :name, :file_path])
    |> validate_length(:name, min: 1, max: 255)
  end
end
