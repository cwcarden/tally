defmodule TallyWeb.Settings.BreedsLive do
  use TallyWeb, :live_view

  alias Tally.Livestock
  alias Tally.Livestock.Breed

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Breeds")
     |> assign(:breeds, Livestock.list_breeds())
     |> assign(:show_form, false)
     |> assign(:form_breed, nil)
     |> assign(:changeset, nil)}
  end

  def handle_event("new_breed", _, socket) do
    {:noreply, socket |> assign(:show_form, true) |> assign(:form_breed, %Breed{}) |> assign(:changeset, Livestock.change_breed(%Breed{}))}
  end

  def handle_event("edit_breed", %{"id" => id}, socket) do
    b = Livestock.get_breed!(id)
    {:noreply, socket |> assign(:show_form, true) |> assign(:form_breed, b) |> assign(:changeset, Livestock.change_breed(b))}
  end

  def handle_event("close_form", _, socket), do: {:noreply, assign(socket, show_form: false)}

  def handle_event("save_breed", %{"breed" => params}, socket) do
    result = case socket.assigns.form_breed do
      %Breed{id: nil} -> Livestock.create_breed(params)
      b -> Livestock.update_breed(b, params)
    end
    case result do
      {:ok, _} -> {:noreply, socket |> put_flash(:info, "Saved") |> assign(:show_form, false) |> assign(:breeds, Livestock.list_breeds())}
      {:error, cs} -> {:noreply, assign(socket, :changeset, cs)}
    end
  end

  def handle_event("delete_breed", %{"id" => id}, socket) do
    Livestock.get_breed!(id) |> Livestock.delete_breed()
    {:noreply, socket |> put_flash(:info, "Deleted") |> assign(:breeds, Livestock.list_breeds())}
  end

  def render(assigns) do
    ~H"""
    <div class="space-y-4 max-w-2xl">
      <div class="flex items-center justify-between">
        <h1 class="text-2xl font-bold">Breeds</h1>
        <button class="btn btn-primary btn-sm" phx-click="new_breed"><.icon name="hero-plus" class="size-4" /> Add Breed</button>
      </div>

      <div class="card bg-base-100 border border-base-300">
        <table class="table table-sm">
          <thead><tr><th>Name</th><th>Species</th><th>Description</th><th></th></tr></thead>
          <tbody>
            <tr :for={b <- @breeds} class="hover:bg-base-200/50">
              <td class="font-medium">{b.name}</td>
              <td>{b.species}</td>
              <td class="text-base-content/60 max-w-xs truncate">{b.description}</td>
              <td>
                <div class="flex gap-1">
                  <button class="btn btn-ghost btn-xs" phx-click="edit_breed" phx-value-id={b.id}><.icon name="hero-pencil" class="size-3.5" /></button>
                  <button class="btn btn-ghost btn-xs text-error" phx-click="delete_breed" phx-value-id={b.id} data-confirm="Delete?"><.icon name="hero-trash" class="size-3.5" /></button>
                </div>
              </td>
            </tr>
          </tbody>
        </table>
        <p :if={@breeds == []} class="text-center text-base-content/50 py-8 text-sm">No breeds yet.</p>
      </div>

      <div :if={@show_form} class="fixed inset-0 z-50 flex">
        <div class="absolute inset-0 bg-black/40" phx-click="close_form"></div>
        <div class="relative ml-auto w-full max-w-sm bg-base-100 h-full overflow-y-auto shadow-2xl">
          <div class="sticky top-0 bg-base-100 border-b border-base-300 px-6 py-4 flex items-center justify-between">
            <h2 class="font-bold text-lg">{if @form_breed && @form_breed.id, do: "Edit Breed", else: "New Breed"}</h2>
            <button class="btn btn-ghost btn-sm" phx-click="close_form"><.icon name="hero-x-mark" class="size-5" /></button>
          </div>
          <div class="p-6">
            <.form for={@changeset} phx-submit="save_breed" class="space-y-4">
              <div class="form-control">
                <label class="label"><span class="label-text">Name *</span></label>
                <.input field={@changeset[:name]} type="text" class="input input-bordered w-full" />
              </div>
              <div class="form-control">
                <label class="label"><span class="label-text">Species *</span></label>
                <.input field={@changeset[:species]} type="select" options={[{"Horse","horse"},{"Cattle","cattle"},{"Dog","dog"},{"Other","other"}]} class="select select-bordered w-full" />
              </div>
              <div class="form-control">
                <label class="label"><span class="label-text">Description</span></label>
                <.input field={@changeset[:description]} type="textarea" class="textarea textarea-bordered w-full" rows="2" />
              </div>
              <div class="flex gap-3 pt-2">
                <button type="submit" class="btn btn-primary flex-1">Save</button>
                <button type="button" class="btn btn-ghost" phx-click="close_form">Cancel</button>
              </div>
            </.form>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
