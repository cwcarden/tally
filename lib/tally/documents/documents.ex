defmodule Tally.Documents do
  @moduledoc """
  The Documents context manages files attached to animals and events.
  """

  import Ecto.Query, warn: false
  alias Tally.Repo
  alias Tally.Documents.AnimalDocument

  def list_documents_for_animal(animal_id) do
    AnimalDocument
    |> where([d], d.animal_id == ^animal_id)
    |> order_by([d], desc: d.inserted_at)
    |> Repo.all()
  end

  def get_document!(id), do: Repo.get!(AnimalDocument, id)

  def create_document(attrs \\ %{}) do
    %AnimalDocument{}
    |> AnimalDocument.changeset(attrs)
    |> Repo.insert()
  end

  def update_document(%AnimalDocument{} = doc, attrs) do
    doc
    |> AnimalDocument.changeset(attrs)
    |> Repo.update()
  end

  def delete_document(%AnimalDocument{} = doc), do: Repo.delete(doc)

  def change_document(%AnimalDocument{} = doc, attrs \\ %{}) do
    AnimalDocument.changeset(doc, attrs)
  end
end
