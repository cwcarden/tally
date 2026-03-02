defmodule TallyWeb.Finance.IncomeLive do
  use TallyWeb, :live_view

  alias Tally.Finance
  alias Tally.Finance.Income

  def mount(_params, _session, socket) do
    categories = Finance.list_income_categories()
    animals = Tally.Livestock.list_animals()
    incomes = Finance.list_incomes()

    {:ok,
     socket
     |> assign(:page_title, "Income")
     |> assign(:incomes, incomes)
     |> assign(:categories, categories)
     |> assign(:animals, animals)
     |> assign(:show_form, false)
     |> assign(:form_income, nil)
     |> assign(:changeset, nil)}
  end

  def handle_event("new_income", _, socket) do
    {:noreply, socket |> assign(:show_form, true) |> assign(:form_income, %Income{}) |> assign(:changeset, Finance.change_income(%Income{}))}
  end

  def handle_event("edit_income", %{"id" => id}, socket) do
    income = Finance.get_income!(id)
    {:noreply, socket |> assign(:show_form, true) |> assign(:form_income, income) |> assign(:changeset, Finance.change_income(income))}
  end

  def handle_event("close_form", _, socket), do: {:noreply, assign(socket, show_form: false)}

  def handle_event("save_income", %{"income" => params}, socket) do
    result = case socket.assigns.form_income do
      %Income{id: nil} -> Finance.create_income(params)
      income -> Finance.update_income(income, params)
    end
    case result do
      {:ok, _} ->
        {:noreply, socket |> put_flash(:info, "Saved") |> assign(:show_form, false) |> assign(:incomes, Finance.list_incomes())}
      {:error, cs} -> {:noreply, assign(socket, :changeset, cs)}
    end
  end

  def handle_event("delete_income", %{"id" => id}, socket) do
    Finance.get_income!(id) |> Finance.delete_income()
    {:noreply, socket |> put_flash(:info, "Deleted") |> assign(:incomes, Finance.list_incomes())}
  end

  def render(assigns) do
    ~H"""
    <div class="space-y-4">
      <div class="flex items-center justify-between">
        <h1 class="text-2xl font-bold">Income</h1>
        <button class="btn btn-primary btn-sm" phx-click="new_income">
          <.icon name="hero-plus" class="size-4" /> Add Income
        </button>
      </div>

      <div class="card bg-base-100 border border-base-300 overflow-x-auto">
        <table class="table table-sm">
          <thead>
            <tr><th>Date</th><th>Category</th><th>Buyer</th><th>Animal</th><th>Memo</th><th class="text-right">Amount</th><th></th></tr>
          </thead>
          <tbody>
            <tr :for={i <- @incomes} class="hover:bg-base-200/50">
              <td class="whitespace-nowrap">{Calendar.strftime(i.txn_date, "%m/%d/%Y")}</td>
              <td>{i.category.name}</td>
              <td>{i.buyer}</td>
              <td>{i.animal && i.animal.tag}</td>
              <td class="max-w-xs truncate">{i.memo}</td>
              <td class="text-right font-mono">${format_money(i.amount)}</td>
              <td>
                <div class="flex gap-1">
                  <button class="btn btn-ghost btn-xs" phx-click="edit_income" phx-value-id={i.id}><.icon name="hero-pencil" class="size-3.5" /></button>
                  <button class="btn btn-ghost btn-xs text-error" phx-click="delete_income" phx-value-id={i.id} data-confirm="Delete?"><.icon name="hero-trash" class="size-3.5" /></button>
                </div>
              </td>
            </tr>
          </tbody>
          <tfoot>
            <tr class="font-bold">
              <td colspan="5" class="text-right">Total</td>
              <td class="text-right font-mono">${total_amount(@incomes)}</td>
              <td></td>
            </tr>
          </tfoot>
        </table>
      </div>

      <div :if={@show_form} class="fixed inset-0 z-50 flex">
        <div class="absolute inset-0 bg-black/40" phx-click="close_form"></div>
        <div class="relative ml-auto w-full max-w-md bg-base-100 h-full overflow-y-auto shadow-2xl">
          <div class="sticky top-0 bg-base-100 border-b border-base-300 px-6 py-4 flex items-center justify-between">
            <h2 class="font-bold text-lg">{if @form_income && @form_income.id, do: "Edit Income", else: "New Income"}</h2>
            <button class="btn btn-ghost btn-sm" phx-click="close_form"><.icon name="hero-x-mark" class="size-5" /></button>
          </div>
          <div class="p-6">
            <.form for={@changeset} phx-submit="save_income" class="space-y-4">
              <div class="form-control">
                <label class="label"><span class="label-text">Date *</span></label>
                <.input field={@changeset[:txn_date]} type="date" class="input input-bordered w-full" />
              </div>
              <div class="form-control">
                <label class="label"><span class="label-text">Category *</span></label>
                <.input field={@changeset[:category_id]} type="select" options={for c <- @categories, do: {c.name, c.id}} class="select select-bordered w-full" />
              </div>
              <div class="form-control">
                <label class="label"><span class="label-text">Amount *</span></label>
                <.input field={@changeset[:amount]} type="number" step="0.01" min="0.01" class="input input-bordered w-full" />
              </div>
              <div class="form-control">
                <label class="label"><span class="label-text">Buyer</span></label>
                <.input field={@changeset[:buyer]} type="text" class="input input-bordered w-full" />
              </div>
              <div class="form-control">
                <label class="label"><span class="label-text">Animal</span></label>
                <.input field={@changeset[:animal_id]} type="select" options={[{"— None —", nil} | for(a <- @animals, do: {"#{a.tag}#{if a.name, do: " — #{a.name}", else: ""}", a.id})]} class="select select-bordered w-full" />
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
  defp total_amount(items), do: items |> Enum.reduce(Decimal.new(0), fn i, acc -> Decimal.add(acc, i.amount) end) |> Decimal.round(2) |> Decimal.to_string(:normal)
end
