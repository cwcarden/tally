defmodule TallyWeb.Finance.VendorsLive do
  use TallyWeb, :live_view

  alias Tally.Finance
  alias Tally.Finance.Vendor

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Vendors")
     |> assign(:vendors, Finance.list_vendors())
     |> assign(:show_form, false)
     |> assign(:form_vendor, nil)
     |> assign(:changeset, nil)}
  end

  def handle_event("new_vendor", _, socket) do
    {:noreply, socket |> assign(:show_form, true) |> assign(:form_vendor, %Vendor{}) |> assign(:changeset, Finance.change_vendor(%Vendor{}))}
  end

  def handle_event("edit_vendor", %{"id" => id}, socket) do
    v = Finance.get_vendor!(id)
    {:noreply, socket |> assign(:show_form, true) |> assign(:form_vendor, v) |> assign(:changeset, Finance.change_vendor(v))}
  end

  def handle_event("close_form", _, socket), do: {:noreply, assign(socket, show_form: false)}

  def handle_event("save_vendor", %{"vendor" => params}, socket) do
    result = case socket.assigns.form_vendor do
      %Vendor{id: nil} -> Finance.create_vendor(params)
      v -> Finance.update_vendor(v, params)
    end
    case result do
      {:ok, _} -> {:noreply, socket |> put_flash(:info, "Saved") |> assign(:show_form, false) |> assign(:vendors, Finance.list_vendors())}
      {:error, cs} -> {:noreply, assign(socket, :changeset, cs)}
    end
  end

  def handle_event("delete_vendor", %{"id" => id}, socket) do
    Finance.get_vendor!(id) |> Finance.delete_vendor()
    {:noreply, socket |> put_flash(:info, "Deleted") |> assign(:vendors, Finance.list_vendors())}
  end

  def render(assigns) do
    ~H"""
    <div class="space-y-4">
      <div class="flex items-center justify-between">
        <h1 class="text-2xl font-bold">Vendors</h1>
        <button class="btn btn-primary btn-sm" phx-click="new_vendor"><.icon name="hero-plus" class="size-4" /> Add Vendor</button>
      </div>

      <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
        <div :for={v <- @vendors} class="card bg-base-100 border border-base-300">
          <div class="card-body p-4">
            <div class="flex items-start justify-between">
              <div>
                <div class="font-bold">{v.name}</div>
                <div :if={v.email} class="text-sm text-base-content/60">{v.email}</div>
                <div :if={v.phone} class="text-sm text-base-content/60">{v.phone}</div>
              </div>
              <div class="flex gap-1">
                <button class="btn btn-ghost btn-xs" phx-click="edit_vendor" phx-value-id={v.id}><.icon name="hero-pencil" class="size-3.5" /></button>
                <button class="btn btn-ghost btn-xs text-error" phx-click="delete_vendor" phx-value-id={v.id} data-confirm="Delete?"><.icon name="hero-trash" class="size-3.5" /></button>
              </div>
            </div>
            <div :if={v.issue_1099} class="badge badge-outline badge-sm mt-2">1099</div>
          </div>
        </div>
      </div>

      <p :if={@vendors == []} class="text-center text-base-content/50 py-12">No vendors yet.</p>

      <div :if={@show_form} class="fixed inset-0 z-50 flex">
        <div class="absolute inset-0 bg-black/40" phx-click="close_form"></div>
        <div class="relative ml-auto w-full max-w-md bg-base-100 h-full overflow-y-auto shadow-2xl">
          <div class="sticky top-0 bg-base-100 border-b border-base-300 px-6 py-4 flex items-center justify-between">
            <h2 class="font-bold text-lg">{if @form_vendor && @form_vendor.id, do: "Edit Vendor", else: "New Vendor"}</h2>
            <button class="btn btn-ghost btn-sm" phx-click="close_form"><.icon name="hero-x-mark" class="size-5" /></button>
          </div>
          <div class="p-6">
            <.form for={@changeset} phx-submit="save_vendor" class="space-y-3">
              <div class="form-control">
                <label class="label"><span class="label-text">Name *</span></label>
                <.input field={@changeset[:name]} type="text" class="input input-bordered w-full" />
              </div>
              <div class="grid grid-cols-2 gap-3">
                <div class="form-control">
                  <label class="label"><span class="label-text">Email</span></label>
                  <.input field={@changeset[:email]} type="email" class="input input-bordered w-full" />
                </div>
                <div class="form-control">
                  <label class="label"><span class="label-text">Phone</span></label>
                  <.input field={@changeset[:phone]} type="text" class="input input-bordered w-full" />
                </div>
              </div>
              <div class="form-control">
                <label class="label"><span class="label-text">Address</span></label>
                <.input field={@changeset[:address1]} type="text" placeholder="Address line 1" class="input input-bordered w-full" />
                <.input field={@changeset[:address2]} type="text" placeholder="Address line 2" class="input input-bordered w-full mt-1" />
              </div>
              <div class="grid grid-cols-3 gap-2">
                <div class="form-control col-span-2">
                  <.input field={@changeset[:city]} type="text" placeholder="City" class="input input-bordered w-full" />
                </div>
                <div class="form-control">
                  <.input field={@changeset[:state]} type="text" placeholder="ST" class="input input-bordered w-full" maxlength="2" />
                </div>
              </div>
              <div class="form-control">
                <label class="label"><span class="label-text">TIN / EIN</span></label>
                <.input field={@changeset[:tin]} type="text" class="input input-bordered w-full" />
              </div>
              <div class="flex items-center gap-4">
                <label class="flex items-center gap-2 cursor-pointer">
                  <.input field={@changeset[:issue_1099]} type="checkbox" class="checkbox checkbox-sm" />
                  <span class="label-text">Issue 1099</span>
                </label>
                <label class="flex items-center gap-2 cursor-pointer">
                  <.input field={@changeset[:is_attorney]} type="checkbox" class="checkbox checkbox-sm" />
                  <span class="label-text">Attorney</span>
                </label>
              </div>
              <div class="form-control">
                <label class="label"><span class="label-text">Notes</span></label>
                <.input field={@changeset[:notes]} type="textarea" class="textarea textarea-bordered w-full" rows="2" />
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
