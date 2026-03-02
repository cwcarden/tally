defmodule TallyWeb.Finance.ExpensesLive do
  use TallyWeb, :live_view

  alias Tally.Finance
  alias Tally.Finance.Expense

  def mount(_params, _session, socket) do
    categories = Finance.list_expense_categories()
    vendors = Finance.list_vendors()
    animals = Tally.Livestock.list_animals()
    expenses = Finance.list_expenses()

    {:ok,
     socket
     |> assign(:page_title, "Expenses")
     |> assign(:expenses, expenses)
     |> assign(:categories, categories)
     |> assign(:vendors, vendors)
     |> assign(:animals, animals)
     |> assign(:show_form, false)
     |> assign(:form_expense, nil)
     |> assign(:changeset, nil)}
  end

  def handle_event("new_expense", _, socket) do
    changeset = Finance.change_expense(%Expense{})
    {:noreply, socket |> assign(:show_form, true) |> assign(:form_expense, %Expense{}) |> assign(:changeset, changeset)}
  end

  def handle_event("edit_expense", %{"id" => id}, socket) do
    expense = Finance.get_expense!(id)
    changeset = Finance.change_expense(expense)
    {:noreply, socket |> assign(:show_form, true) |> assign(:form_expense, expense) |> assign(:changeset, changeset)}
  end

  def handle_event("close_form", _, socket) do
    {:noreply, assign(socket, show_form: false)}
  end

  def handle_event("save_expense", %{"expense" => params}, socket) do
    result = case socket.assigns.form_expense do
      %Expense{id: nil} -> Finance.create_expense(params)
      expense -> Finance.update_expense(expense, params)
    end
    case result do
      {:ok, _} ->
        expenses = Finance.list_expenses()
        {:noreply, socket |> put_flash(:info, "Saved") |> assign(:show_form, false) |> assign(:expenses, expenses)}
      {:error, cs} ->
        {:noreply, assign(socket, :changeset, cs)}
    end
  end

  def handle_event("delete_expense", %{"id" => id}, socket) do
    Finance.get_expense!(id) |> Finance.delete_expense()
    expenses = Finance.list_expenses()
    {:noreply, socket |> put_flash(:info, "Deleted") |> assign(:expenses, expenses)}
  end

  def render(assigns) do
    ~H"""
    <div class="space-y-4">
      <div class="flex items-center justify-between">
        <h1 class="text-2xl font-bold">Expenses</h1>
        <button class="btn btn-primary btn-sm" phx-click="new_expense">
          <.icon name="hero-plus" class="size-4" /> Add Expense
        </button>
      </div>

      <div class="card bg-base-100 border border-base-300 overflow-x-auto">
        <table class="table table-sm">
          <thead>
            <tr>
              <th>Date</th><th>Category</th><th>Vendor</th><th>Animal</th><th>Memo</th>
              <th class="text-right">Amount</th><th></th>
            </tr>
          </thead>
          <tbody>
            <tr :for={e <- @expenses} class="hover:bg-base-200/50">
              <td class="whitespace-nowrap">{Calendar.strftime(e.txn_date, "%m/%d/%Y")}</td>
              <td>{e.category.name}</td>
              <td>{e.vendor && e.vendor.name}</td>
              <td>{e.animal && e.animal.tag}</td>
              <td class="max-w-xs truncate">{e.memo}</td>
              <td class="text-right font-mono">${format_money(e.amount)}</td>
              <td>
                <div class="flex gap-1">
                  <button class="btn btn-ghost btn-xs" phx-click="edit_expense" phx-value-id={e.id}>
                    <.icon name="hero-pencil" class="size-3.5" />
                  </button>
                  <button class="btn btn-ghost btn-xs text-error" phx-click="delete_expense" phx-value-id={e.id}
                    data-confirm="Delete this expense?">
                    <.icon name="hero-trash" class="size-3.5" />
                  </button>
                </div>
              </td>
            </tr>
          </tbody>
          <tfoot>
            <tr class="font-bold">
              <td colspan="5" class="text-right">Total</td>
              <td class="text-right font-mono">${total_amount(@expenses)}</td>
              <td></td>
            </tr>
          </tfoot>
        </table>
      </div>

      <div :if={@show_form} class="fixed inset-0 z-50 flex">
        <div class="absolute inset-0 bg-black/40" phx-click="close_form"></div>
        <div class="relative ml-auto w-full max-w-md bg-base-100 h-full overflow-y-auto shadow-2xl">
          <div class="sticky top-0 bg-base-100 border-b border-base-300 px-6 py-4 flex items-center justify-between">
            <h2 class="font-bold text-lg">{if @form_expense && @form_expense.id, do: "Edit Expense", else: "New Expense"}</h2>
            <button class="btn btn-ghost btn-sm" phx-click="close_form"><.icon name="hero-x-mark" class="size-5" /></button>
          </div>
          <div class="p-6">
            <.form for={@changeset} phx-submit="save_expense" class="space-y-4">
              <div class="form-control">
                <label class="label"><span class="label-text">Date *</span></label>
                <.input field={@changeset[:txn_date]} type="date" class="input input-bordered w-full" />
              </div>
              <div class="form-control">
                <label class="label"><span class="label-text">Category *</span></label>
                <.input field={@changeset[:category_id]} type="select"
                  options={for c <- @categories, do: {c.name, c.id}}
                  class="select select-bordered w-full" />
              </div>
              <div class="form-control">
                <label class="label"><span class="label-text">Amount *</span></label>
                <.input field={@changeset[:amount]} type="number" step="0.01" min="0.01" class="input input-bordered w-full" />
              </div>
              <div class="form-control">
                <label class="label"><span class="label-text">Vendor</span></label>
                <.input field={@changeset[:vendor_id]} type="select"
                  options={[{"— None —", nil} | for(v <- @vendors, do: {v.name, v.id})] }
                  class="select select-bordered w-full" />
              </div>
              <div class="form-control">
                <label class="label"><span class="label-text">Animal</span></label>
                <.input field={@changeset[:animal_id]} type="select"
                  options={[{"— None —", nil} | for(a <- @animals, do: {"#{a.tag}#{if a.name, do: " — #{a.name}", else: ""}", a.id})]}
                  class="select select-bordered w-full" />
              </div>
              <div class="form-control">
                <label class="label"><span class="label-text">Memo</span></label>
                <.input field={@changeset[:memo]} type="text" class="input input-bordered w-full" />
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

  defp format_money(%Decimal{} = d), do: d |> Decimal.round(2) |> Decimal.to_string(:normal)
  defp format_money(_), do: "0.00"

  defp total_amount(items) do
    items
    |> Enum.reduce(Decimal.new(0), fn e, acc -> Decimal.add(acc, e.amount) end)
    |> Decimal.round(2)
    |> Decimal.to_string(:normal)
  end
end
