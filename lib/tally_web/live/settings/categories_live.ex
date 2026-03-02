defmodule TallyWeb.Settings.CategoriesLive do
  use TallyWeb, :live_view

  alias Tally.Finance
  alias Tally.Finance.Category

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Categories")
     |> assign(:categories, Finance.list_categories())
     |> assign(:show_form, false)
     |> assign(:form_cat, nil)
     |> assign(:changeset, nil)}
  end

  def handle_event("new_cat", _, socket) do
    {:noreply, socket |> assign(:show_form, true) |> assign(:form_cat, %Category{}) |> assign(:changeset, Finance.change_category(%Category{}))}
  end

  def handle_event("edit_cat", %{"id" => id}, socket) do
    c = Finance.get_category!(id)
    {:noreply, socket |> assign(:show_form, true) |> assign(:form_cat, c) |> assign(:changeset, Finance.change_category(c))}
  end

  def handle_event("close_form", _, socket), do: {:noreply, assign(socket, show_form: false)}

  def handle_event("save_cat", %{"category" => params}, socket) do
    result = case socket.assigns.form_cat do
      %Category{id: nil} -> Finance.create_category(params)
      c -> Finance.update_category(c, params)
    end
    case result do
      {:ok, _} -> {:noreply, socket |> put_flash(:info, "Saved") |> assign(:show_form, false) |> assign(:categories, Finance.list_categories())}
      {:error, cs} -> {:noreply, assign(socket, :changeset, cs)}
    end
  end

  def handle_event("delete_cat", %{"id" => id}, socket) do
    Finance.get_category!(id) |> Finance.delete_category()
    {:noreply, socket |> put_flash(:info, "Deleted") |> assign(:categories, Finance.list_categories())}
  end

  def render(assigns) do
    ~H"""
    <div class="space-y-4 max-w-2xl">
      <div class="flex items-center justify-between">
        <h1 class="text-2xl font-bold">Categories</h1>
        <button class="btn btn-primary btn-sm" phx-click="new_cat"><.icon name="hero-plus" class="size-4" /> Add Category</button>
      </div>

      <div class="card bg-base-100 border border-base-300">
        <table class="table table-sm">
          <thead><tr><th>Name</th><th>Kind</th><th>Report Form</th><th></th></tr></thead>
          <tbody>
            <tr :for={c <- @categories} class="hover:bg-base-200/50">
              <td class="font-medium">{c.name}</td>
              <td><span class={["badge badge-sm", if(c.kind == "expense", do: "badge-error", else: "badge-success")]}>{c.kind}</span></td>
              <td class="text-base-content/60">{c.report_form}</td>
              <td>
                <div class="flex gap-1">
                  <button class="btn btn-ghost btn-xs" phx-click="edit_cat" phx-value-id={c.id}><.icon name="hero-pencil" class="size-3.5" /></button>
                  <button class="btn btn-ghost btn-xs text-error" phx-click="delete_cat" phx-value-id={c.id} data-confirm="Delete?"><.icon name="hero-trash" class="size-3.5" /></button>
                </div>
              </td>
            </tr>
          </tbody>
        </table>
        <p :if={@categories == []} class="text-center text-base-content/50 py-8 text-sm">No categories yet.</p>
      </div>

      <div :if={@show_form} class="fixed inset-0 z-50 flex">
        <div class="absolute inset-0 bg-black/40" phx-click="close_form"></div>
        <div class="relative ml-auto w-full max-w-sm bg-base-100 h-full overflow-y-auto shadow-2xl">
          <div class="sticky top-0 bg-base-100 border-b border-base-300 px-6 py-4 flex items-center justify-between">
            <h2 class="font-bold text-lg">{if @form_cat && @form_cat.id, do: "Edit Category", else: "New Category"}</h2>
            <button class="btn btn-ghost btn-sm" phx-click="close_form"><.icon name="hero-x-mark" class="size-5" /></button>
          </div>
          <div class="p-6">
            <.form for={@changeset} phx-submit="save_cat" class="space-y-4">
              <div class="form-control">
                <label class="label"><span class="label-text">Name *</span></label>
                <.input field={@changeset[:name]} type="text" class="input input-bordered w-full" />
              </div>
              <div class="form-control">
                <label class="label"><span class="label-text">Kind *</span></label>
                <.input field={@changeset[:kind]} type="select" options={[{"Expense","expense"},{"Income","income"}]} class="select select-bordered w-full" />
              </div>
              <div class="form-control">
                <label class="label"><span class="label-text">Report Form</span></label>
                <.input field={@changeset[:report_form]} type="select" options={[{"None","none"},{"NEC","nec"},{"Misc 1","misc1"},{"Misc 6","misc6"},{"Misc 10","misc10"}]} class="select select-bordered w-full" />
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
