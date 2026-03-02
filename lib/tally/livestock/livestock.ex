defmodule Tally.Livestock do
  @moduledoc """
  The Livestock context manages animals, breeds, and event types.
  """

  import Ecto.Query, warn: false
  alias Tally.Repo
  alias Tally.Livestock.{Animal, Breed, EventType}

  # ──────────────────── Breeds ────────────────────

  def list_breeds do
    Repo.all(from b in Breed, order_by: [asc: b.name])
  end

  def get_breed!(id), do: Repo.get!(Breed, id)

  def create_breed(attrs \\ %{}) do
    %Breed{}
    |> Breed.changeset(attrs)
    |> Repo.insert()
  end

  def update_breed(%Breed{} = breed, attrs) do
    breed
    |> Breed.changeset(attrs)
    |> Repo.update()
  end

  def delete_breed(%Breed{} = breed), do: Repo.delete(breed)

  def change_breed(%Breed{} = breed, attrs \\ %{}) do
    Breed.changeset(breed, attrs)
  end

  # ──────────────────── Event Types ────────────────────

  def list_event_types do
    Repo.all(from et in EventType, order_by: [asc: et.name])
  end

  def get_event_type!(id), do: Repo.get!(EventType, id)

  def create_event_type(attrs \\ %{}) do
    %EventType{}
    |> EventType.changeset(attrs)
    |> Repo.insert()
  end

  def update_event_type(%EventType{} = et, attrs) do
    et
    |> EventType.changeset(attrs)
    |> Repo.update()
  end

  def delete_event_type(%EventType{} = et), do: Repo.delete(et)

  def change_event_type(%EventType{} = et, attrs \\ %{}) do
    EventType.changeset(et, attrs)
  end

  # ──────────────────── Animals ────────────────────

  def list_animals(filters \\ %{}) do
    Animal
    |> apply_animal_filters(filters)
    |> preload([:breed, :sire, :dam])
    |> order_by([a], asc: a.kind, asc: a.tag)
    |> Repo.all()
  end

  defp apply_animal_filters(query, filters) do
    Enum.reduce(filters, query, fn
      {:kind, kind}, q when kind != "" -> where(q, [a], a.kind == ^kind)
      {:status, status}, q when status != "" -> where(q, [a], a.status == ^status)
      {:owned, "true"}, q -> where(q, [a], a.owned == true)
      {:owned, "false"}, q -> where(q, [a], a.owned == false)
      {:search, term}, q when term != "" ->
        like = "%#{term}%"
        where(q, [a], ilike(a.tag, ^like) or ilike(a.name, ^like))
      _, q -> q
    end)
  end

  def get_animal!(id) do
    Repo.get!(Animal, id)
    |> Repo.preload([:breed, :sire, :dam, :animal_events, :animal_documents])
  end

  def create_animal(attrs \\ %{}) do
    %Animal{}
    |> Animal.changeset(attrs)
    |> Repo.insert()
  end

  def update_animal(%Animal{} = animal, attrs) do
    animal
    |> Animal.changeset(attrs)
    |> Repo.update()
  end

  def delete_animal(%Animal{} = animal), do: Repo.delete(animal)

  def change_animal(%Animal{} = animal, attrs \\ %{}) do
    Animal.changeset(animal, attrs)
  end

  @doc """
  Returns a 4-generation pedigree map for the given animal.
  """
  def pedigree(%Animal{} = animal) do
    animal = Repo.preload(animal, [
      sire: [sire: [:sire, :dam], dam: [:sire, :dam]],
      dam: [sire: [:sire, :dam], dam: [:sire, :dam]]
    ])

    %{
      subject: animal,
      sire: build_pedigree_node(animal.sire),
      dam: build_pedigree_node(animal.dam)
    }
  end

  defp build_pedigree_node(nil), do: nil
  defp build_pedigree_node(animal) do
    %{
      animal: animal,
      sire: build_pedigree_node(animal.sire),
      dam: build_pedigree_node(animal.dam)
    }
  end

  @doc """
  Returns all offspring of an animal (as sire or dam).
  """
  def list_offspring(%Animal{id: id}) do
    Animal
    |> where([a], a.sire_id == ^id or a.dam_id == ^id)
    |> order_by([a], asc: a.tag)
    |> Repo.all()
  end

  @doc """
  Returns animals suitable to be sire (stallion, bull, male).
  """
  def list_potential_sires(kind) do
    male_sexes = sire_sexes(kind)
    Animal
    |> where([a], a.kind == ^kind and a.sex in ^male_sexes)
    |> order_by([a], asc: a.tag)
    |> Repo.all()
  end

  @doc """
  Returns animals suitable to be dam (mare, cow, female).
  """
  def list_potential_dams(kind) do
    female_sexes = dam_sexes(kind)
    Animal
    |> where([a], a.kind == ^kind and a.sex in ^female_sexes)
    |> order_by([a], asc: a.tag)
    |> Repo.all()
  end

  defp sire_sexes("horse"), do: ["stallion"]
  defp sire_sexes("cattle"), do: ["bull"]
  defp sire_sexes(_), do: ["male"]

  defp dam_sexes("horse"), do: ["mare"]
  defp dam_sexes("cattle"), do: ["cow"]
  defp dam_sexes(_), do: ["female"]
end
