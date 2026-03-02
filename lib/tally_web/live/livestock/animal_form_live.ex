defmodule TallyWeb.Livestock.AnimalFormLive do
  use TallyWeb, :live_view

  alias Tally.{Livestock, Uploads}
  alias Tally.Livestock.Animal

  def mount(%{"id" => id}, _session, socket) do
    animal = Livestock.get_animal!(id)
    changeset = Livestock.change_animal(animal)
    breeds = Livestock.list_breeds()
    potential_sires = Livestock.list_potential_sires(animal.kind)
    potential_dams = Livestock.list_potential_dams(animal.kind)

    {:ok,
     socket
     |> assign(:page_title, "Edit #{animal.tag}")
     |> assign(:animal, animal)
     |> assign(:changeset, changeset)
     |> assign(:breeds, breeds)
     |> assign(:potential_sires, potential_sires)
     |> assign(:potential_dams, potential_dams)
     |> allow_upload(:thumbnail, accept: ~w(image/*), max_entries: 1, max_file_size: 5_000_000)}
  end

  def handle_event("validate", %{"animal" => params}, socket) do
    changeset =
      socket.assigns.animal
      |> Livestock.change_animal(params)
      |> Map.put(:action, :validate)
    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"animal" => params}, socket) do
    animal = socket.assigns.animal

    thumbnail_path =
      consume_uploaded_entries(socket, :thumbnail, fn %{path: tmp}, entry ->
        case Uploads.store_thumbnail(tmp, entry, animal.id) do
          {:ok, path} -> {:ok, path}
          _ -> {:ok, animal.thumbnail_path}
        end
      end)
      |> List.first()

    final_params =
      if thumbnail_path,
        do: Map.put(params, "thumbnail_path", thumbnail_path),
        else: params

    case Livestock.update_animal(animal, final_params) do
      {:ok, updated} ->
        {:noreply, socket |> put_flash(:info, "Animal saved") |> push_navigate(to: ~p"/livestock/#{updated.id}")}
      {:error, changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  def render(assigns) do
    ~H"""
    <div class="max-w-2xl space-y-4">
      <div class="breadcrumbs text-sm">
        <ul>
          <li><.link href={~p"/livestock"}>Animals</.link></li>
          <li><.link href={~p"/livestock/#{@animal.id}"}>{@animal.tag}</.link></li>
          <li>Edit</li>
        </ul>
      </div>

      <div class="card bg-base-100 border border-base-300">
        <div class="card-body p-6">
          <h1 class="card-title">Edit Animal</h1>

          <.form for={@changeset} phx-change="validate" phx-submit="save" class="space-y-4 mt-4">
            <div class="grid grid-cols-2 gap-4">
              <div class="form-control">
                <label class="label"><span class="label-text font-medium">Tag *</span></label>
                <.input field={@changeset[:tag]} type="text" class="input input-bordered" />
              </div>
              <div class="form-control">
                <label class="label"><span class="label-text font-medium">Name</span></label>
                <.input field={@changeset[:name]} type="text" class="input input-bordered" />
              </div>
            </div>

            <div class="grid grid-cols-2 gap-4">
              <div class="form-control">
                <label class="label"><span class="label-text font-medium">Kind *</span></label>
                <.input field={@changeset[:kind]} type="select" options={[{"Horse","horse"},{"Cattle","cattle"},{"Dog","dog"}]} class="select select-bordered" />
              </div>
              <div class="form-control">
                <label class="label"><span class="label-text font-medium">Sex *</span></label>
                <.input field={@changeset[:sex]} type="select" options={for s <- Animal.sexes(), do: {String.capitalize(s), s}} class="select select-bordered" />
              </div>
            </div>

            <div class="grid grid-cols-2 gap-4">
              <div class="form-control">
                <label class="label"><span class="label-text font-medium">Date of Birth</span></label>
                <.input field={@changeset[:dob]} type="date" class="input input-bordered" />
              </div>
              <div class="form-control">
                <label class="label"><span class="label-text font-medium">Breed</span></label>
                <.input field={@changeset[:breed_id]} type="select" options={[{"— None —", nil} | for(b <- @breeds, do: {b.name, b.id})]} class="select select-bordered" />
              </div>
            </div>

            <div class="grid grid-cols-2 gap-4">
              <div class="form-control">
                <label class="label"><span class="label-text font-medium">Sire</span></label>
                <.input field={@changeset[:sire_id]} type="select" options={[{"— None —", nil} | for(a <- @potential_sires, do: {"#{a.tag}#{if a.name, do: " — #{a.name}"}", a.id})]} class="select select-bordered" />
              </div>
              <div class="form-control">
                <label class="label"><span class="label-text font-medium">Dam</span></label>
                <.input field={@changeset[:dam_id]} type="select" options={[{"— None —", nil} | for(a <- @potential_dams, do: {"#{a.tag}#{if a.name, do: " — #{a.name}"}", a.id})]} class="select select-bordered" />
              </div>
            </div>

            <div class="grid grid-cols-2 gap-4">
              <div class="form-control">
                <label class="label"><span class="label-text font-medium">Status</span></label>
                <.input field={@changeset[:status]} type="select" options={for s <- Animal.statuses(), do: {String.capitalize(s), s}} class="select select-bordered" />
              </div>
              <div class="form-control">
                <label class="label"><span class="label-text font-medium">Status Date</span></label>
                <.input field={@changeset[:status_date]} type="date" class="input input-bordered" />
              </div>
            </div>

            <div class="form-control">
              <label class="label"><span class="label-text font-medium">Notes</span></label>
              <.input field={@changeset[:notes]} type="textarea" class="textarea textarea-bordered" rows="3" />
            </div>

            <div class="form-control">
              <label class="label"><span class="label-text font-medium">Thumbnail Photo</span></label>
              <.live_file_input upload={@uploads.thumbnail} class="file-input file-input-bordered w-full" />
            </div>

            <div class="flex items-center gap-2">
              <.input field={@changeset[:owned]} type="checkbox" class="checkbox" />
              <label class="label-text">Owned (on ranch)</label>
            </div>

            <div class="flex gap-3 pt-2">
              <button type="submit" class="btn btn-primary">Save Changes</button>
              <.link href={~p"/livestock/#{@animal.id}"} class="btn btn-ghost">Cancel</.link>
            </div>
          </.form>
        </div>
      </div>
    </div>
    """
  end
end
