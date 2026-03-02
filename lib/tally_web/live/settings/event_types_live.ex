defmodule TallyWeb.Settings.EventTypesLive do
  use TallyWeb, :live_view

  alias Tally.Livestock
  alias Tally.Livestock.EventType

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Event Types")
     |> assign(:event_types, Livestock.list_event_types())
     |> assign(:show_form, false)
     |> assign(:form_et, nil)
     |> assign(:changeset, nil)}
  end

  def handle_event("new_et", _, socket) do
    {:noreply, socket |> assign(:show_form, true) |> assign(:form_et, %EventType{}) |> assign(:changeset, Livestock.change_event_type(%EventType{}))}
  end

  def handle_event("edit_et", %{"id" => id}, socket) do
    et = Livestock.get_event_type!(id)
    {:noreply, socket |> assign(:show_form, true) |> assign(:form_et, et) |> assign(:changeset, Livestock.change_event_type(et))}
  end

  def handle_event("close_form", _, socket), do: {:noreply, assign(socket, show_form: false)}

  def handle_event("save_et", %{"event_type" => params}, socket) do
    result = case socket.assigns.form_et do
      %EventType{id: nil} -> Livestock.create_event_type(params)
      et -> Livestock.update_event_type(et, params)
    end
    case result do
      {:ok, _} -> {:noreply, socket |> put_flash(:info, "Saved") |> assign(:show_form, false) |> assign(:event_types, Livestock.list_event_types())}
      {:error, cs} -> {:noreply, assign(socket, :changeset, cs)}
    end
  end

  def handle_event("delete_et", %{"id" => id}, socket) do
    Livestock.get_event_type!(id) |> Livestock.delete_event_type()
    {:noreply, socket |> put_flash(:info, "Deleted") |> assign(:event_types, Livestock.list_event_types())}
  end

  def render(assigns) do
    ~H"""
    <div class="space-y-4 max-w-2xl">
      <div class="flex items-center justify-between">
        <h1 class="text-2xl font-bold">Event Types</h1>
        <button class="btn btn-primary btn-sm" phx-click="new_et"><.icon name="hero-plus" class="size-4" /> Add Event Type</button>
      </div>

      <div class="card bg-base-100 border border-base-300">
        <table class="table table-sm">
          <thead><tr><th>Name</th><th>Description</th><th></th></tr></thead>
          <tbody>
            <tr :for={et <- @event_types} class="hover:bg-base-200/50">
              <td class="font-medium">{et.name}</td>
              <td class="text-base-content/60 max-w-xs truncate">{et.description}</td>
              <td>
                <div class="flex gap-1">
                  <button class="btn btn-ghost btn-xs" phx-click="edit_et" phx-value-id={et.id}><.icon name="hero-pencil" class="size-3.5" /></button>
                  <button class="btn btn-ghost btn-xs text-error" phx-click="delete_et" phx-value-id={et.id} data-confirm="Delete?"><.icon name="hero-trash" class="size-3.5" /></button>
                </div>
              </td>
            </tr>
          </tbody>
        </table>
        <p :if={@event_types == []} class="text-center text-base-content/50 py-8 text-sm">No event types yet.</p>
      </div>

      <div :if={@show_form} class="fixed inset-0 z-50 flex">
        <div class="absolute inset-0 bg-black/40" phx-click="close_form"></div>
        <div class="relative ml-auto w-full max-w-sm bg-base-100 h-full overflow-y-auto shadow-2xl">
          <div class="sticky top-0 bg-base-100 border-b border-base-300 px-6 py-4 flex items-center justify-between">
            <h2 class="font-bold text-lg">{if @form_et && @form_et.id, do: "Edit Event Type", else: "New Event Type"}</h2>
            <button class="btn btn-ghost btn-sm" phx-click="close_form"><.icon name="hero-x-mark" class="size-5" /></button>
          </div>
          <div class="p-6">
            <.form for={@changeset} phx-submit="save_et" class="space-y-4">
              <div class="form-control">
                <label class="label"><span class="label-text">Name *</span></label>
                <.input field={@changeset[:name]} type="text" class="input input-bordered w-full" />
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
