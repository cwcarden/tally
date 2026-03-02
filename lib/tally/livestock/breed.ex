defmodule Tally.Livestock.Breed do
  use Ecto.Schema
  import Ecto.Changeset

  schema "breeds" do
    field :name, :string
    field :species, :string
    field :description, :string

    has_many :animals, Tally.Livestock.Animal

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(breed, attrs) do
    breed
    |> cast(attrs, [:name, :species, :description])
    |> validate_required([:name, :species])
    |> validate_length(:name, min: 1, max: 100)
    |> unique_constraint(:name)
  end
end
