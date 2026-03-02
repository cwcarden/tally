defmodule Tally.Events do
  @moduledoc """
  The Events context manages animal events (vet visits, vaccinations, etc.)
  """

  import Ecto.Query, warn: false
  alias Tally.Repo
  alias Tally.Events.AnimalEvent

  def list_events_for_animal(animal_id) do
    AnimalEvent
    |> where([e], e.animal_id == ^animal_id)
    |> preload([:event_type])
    |> order_by([e], desc: e.happened_on)
    |> Repo.all()
  end

  def get_event!(id) do
    Repo.get!(AnimalEvent, id)
    |> Repo.preload([:event_type, :animal_documents])
  end

  def create_event(attrs \\ %{}) do
    %AnimalEvent{}
    |> AnimalEvent.changeset(attrs)
    |> Repo.insert()
  end

  def update_event(%AnimalEvent{} = event, attrs) do
    event
    |> AnimalEvent.changeset(attrs)
    |> Repo.update()
  end

  def delete_event(%AnimalEvent{} = event), do: Repo.delete(event)

  def change_event(%AnimalEvent{} = event, attrs \\ %{}) do
    AnimalEvent.changeset(event, attrs)
  end
end
