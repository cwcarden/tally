defmodule TallyWeb.Livestock.AnimalListLive do
  use TallyWeb, :live_view

  alias Tally.Livestock
  alias Tally.Livestock.Animal

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Animals")
     |> assign(:filters, %{kind: "", status: "", search: ""})
     |> assign(:show_form, false)
     |> assign(:form_animal, nil)
     |> assign(:changeset, nil)
     |> load_animals()}
  end

  def handle_event("filter", params, socket) do
    filters = %{
      kind: Map.get(params, "kind", ""),
      status: Map.get(params, "status", ""),
      search: Map.get(params, "search", "")
    }
    {:noreply, socket |> assign(:filters, filters) |> load_animals()}
  end

  def handle_event("new_animal", _params, socket) do
    changeset = Livestock.change_animal(%Animal{})
    {:noreply, socket |> assign(:show_form, true) |> assign(:form_animal, %Animal{}) |> assign(:changeset, changeset)}
  end

  def handle_event("close_form", _params, socket) do
    {:noreply, assign(socket, show_form: false, form_animal: nil, changeset: nil)}
  end

  def handle_event("save_animal", %{"animal" => params}, socket) do
    case socket.assigns.form_animal do
      %Animal{id: nil} ->
        case Livestock.create_animal(params) do
          {:ok, _animal} ->
            {:noreply, socket |> put_flash(:info, "Animal added") |> assign(:show_form, false) |> load_animals()}
          {:error, changeset} ->
            {:noreply, assign(socket, :changeset, changeset)}
        end
      animal ->
        case Livestock.update_animal(animal, params) do
          {:ok, _animal} ->
            {:noreply, socket |> put_flash(:info, "Animal updated") |> assign(:show_form, false) |> load_animals()}
          {:error, changeset} ->
            {:noreply, assign(socket, :changeset, changeset)}
        end
    end
  end

  defp load_animals(socket) do
    animals = Livestock.list_animals(socket.assigns.filters)
    assign(socket, :animals, animals)
  end

  def render(assigns) do
    ~H"""
    <div class="space-y-4">
      <%!-- Header --%>
      <div class="flex items-center justify-between">
        <h1 class="text-2xl font-bold">Animals</h1>
        <button class="btn btn-primary btn-sm" phx-click="new_animal">
          <.icon name="hero-plus" class="size-4" /> Add Animal
        </button>
      </div>

      <%!-- Filters --%>
      <div class="card bg-base-100 border border-base-300">
        <div class="card-body p-4">
          <form phx-change="filter" class="flex flex-wrap gap-3">
            <input
              name="search"
              type="text"
              placeholder="Search tag or name…"
              value={@filters.search}
              class="input input-bordered input-sm w-48"
            />
            <select name="kind" class="select select-bordered select-sm">
              <option value="">All kinds</option>
              <option :for={k <- Animal.kinds()} value={k} selected={@filters.kind == k}>{String.capitalize(k)}</option>
            </select>
            <select name="status" class="select select-bordered select-sm">
              <option value="">All statuses</option>
              <option :for={s <- Animal.statuses()} value={s} selected={@filters.status == s}>{String.capitalize(s)}</option>
            </select>
          </form>
        </div>
      </div>

      <%!-- Animal Grid --%>
      <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4">
        <.link :for={animal <- @animals} href={~p"/livestock/#{animal.id}"} class="card bg-base-100 border border-base-300 hover:border-primary hover:shadow-md transition-all">
          <div class="card-body p-4">
            <div class="flex items-start justify-between">
              <div class="min-w-0">
                <div class="font-bold text-base truncate">{animal.tag}</div>
                <div class="text-sm text-base-content/60 truncate">{animal.name}</div>
              </div>
              <span class={["badge badge-sm ml-2 shrink-0", status_badge_class(animal.status)]}>
                {animal.status}
              </span>
            </div>
            <div class="flex items-center gap-2 mt-2 text-xs text-base-content/50">
              <span>{String.capitalize(animal.kind)}</span>
              <span>·</span>
              <span>{format_sex(animal.sex)}</span>
              <span :if={animal.breed}>· {animal.breed.name}</span>
            </div>
          </div>
        </.link>
      </div>

      <p :if={@animals == []} class="text-center text-base-content/50 py-12">
        No animals found. Add your first animal to get started.
      </p>

      <%!-- Slide-over Modal Form --%>
      <div :if={@show_form} class="fixed inset-0 z-50 flex">
        <div class="absolute inset-0 bg-black/40" phx-click="close_form"></div>
        <div class="relative ml-auto w-full max-w-md bg-base-100 h-full overflow-y-auto shadow-2xl">
          <div class="sticky top-0 bg-base-100 border-b border-base-300 px-6 py-4 flex items-center justify-between">
            <h2 class="font-bold text-lg">
              {if @form_animal.id, do: "Edit Animal", else: "New Animal"}
            </h2>
            <button class="btn btn-ghost btn-sm" phx-click="close_form">
              <.icon name="hero-x-mark" class="size-5" />
            </button>
          </div>
          <div class="p-6">
            <.animal_form changeset={@changeset} />
          </div>
        </div>
      </div>
    </div>
    """
  end

  attr :changeset, :any, required: true

  defp animal_form(assigns) do
    ~H"""
    <.form for={@changeset} phx-submit="save_animal" class="space-y-4">
      <div class="form-control">
        <label class="label"><span class="label-text">Tag *</span></label>
        <.input field={@changeset[:tag]} type="text" class="input input-bordered w-full" required />
      </div>
      <div class="form-control">
        <label class="label"><span class="label-text">Name</span></label>
        <.input field={@changeset[:name]} type="text" class="input input-bordered w-full" />
      </div>
      <div class="grid grid-cols-2 gap-3">
        <div class="form-control">
          <label class="label"><span class="label-text">Kind *</span></label>
          <.input field={@changeset[:kind]} type="select" options={[{"Horse","horse"},{"Cattle","cattle"},{"Dog","dog"}]} class="select select-bordered w-full" />
        </div>
        <div class="form-control">
          <label class="label"><span class="label-text">Sex *</span></label>
          <.input field={@changeset[:sex]} type="select" options={for s <- Tally.Livestock.Animal.sexes(), do: {String.capitalize(s), s}} class="select select-bordered w-full" />
        </div>
      </div>
      <div class="form-control">
        <label class="label"><span class="label-text">Date of Birth</span></label>
        <.input field={@changeset[:dob]} type="date" class="input input-bordered w-full" />
      </div>
      <div class="form-control">
        <label class="label"><span class="label-text">Status</span></label>
        <.input field={@changeset[:status]} type="select" options={for s <- Tally.Livestock.Animal.statuses(), do: {String.capitalize(s), s}} class="select select-bordered w-full" />
      </div>
      <div class="form-control">
        <label class="label"><span class="label-text">Notes</span></label>
        <.input field={@changeset[:notes]} type="textarea" class="textarea textarea-bordered w-full" rows="3" />
      </div>
      <div class="flex gap-3 pt-2">
        <button type="submit" class="btn btn-primary flex-1">Save</button>
        <button type="button" class="btn btn-ghost" phx-click="close_form">Cancel</button>
      </div>
    </.form>
    """
  end

  defp status_badge_class("active"), do: "badge-success"
  defp status_badge_class("sold"), do: "badge-info"
  defp status_badge_class("deceased"), do: "badge-error"
  defp status_badge_class("retired"), do: "badge-warning"
  defp status_badge_class(_), do: "badge-ghost"

  defp format_sex(sex), do: sex |> String.capitalize()
end
