defmodule TallyWeb.Finance.DashboardLive do
  use TallyWeb, :live_view

  alias Tally.Finance

  def mount(_params, _session, socket) do
    year = Date.utc_today().year
    summary = Finance.ytd_summary(year)
    {:ok,
     socket
     |> assign(:page_title, "Finance Overview")
     |> assign(:summary, summary)
     |> assign(:selected_year, year)}
  end

  def handle_event("change_year", %{"year" => year_str}, socket) do
    year = String.to_integer(year_str)
    summary = Finance.ytd_summary(year)
    {:noreply, socket |> assign(:summary, summary) |> assign(:selected_year, year)}
  end

  def render(assigns) do
    ~H"""
    <div class="space-y-6">
      <div class="flex items-center justify-between">
        <h1 class="text-2xl font-bold">Finance Overview</h1>
        <form phx-change="change_year">
          <select name="year" class="select select-bordered select-sm">
            <option :for={y <- year_range()} value={y} selected={@selected_year == y}>{y}</option>
          </select>
        </form>
      </div>

      <div class="grid grid-cols-1 sm:grid-cols-3 gap-4">
        <div class="stat bg-base-100 border border-base-300 rounded-box">
          <div class="stat-title">Total Income</div>
          <div class="stat-value text-success text-2xl">${format_money(@summary.total_income)}</div>
          <div class="stat-desc">{@summary.year}</div>
        </div>
        <div class="stat bg-base-100 border border-base-300 rounded-box">
          <div class="stat-title">Total Expenses</div>
          <div class="stat-value text-error text-2xl">${format_money(@summary.total_expenses)}</div>
          <div class="stat-desc">{@summary.year}</div>
        </div>
        <div class="stat bg-base-100 border border-base-300 rounded-box">
          <div class="stat-title">Net</div>
          <div class={["stat-value text-2xl", if(Decimal.compare(@summary.net, 0) != :lt, do: "text-success", else: "text-error")]}>
            ${format_money(@summary.net)}
          </div>
          <div class="stat-desc">{@summary.year}</div>
        </div>
      </div>

      <div class="grid grid-cols-2 sm:grid-cols-4 gap-4">
        <.link href={~p"/finance/expenses"} class="card bg-base-100 border border-base-300 hover:border-primary transition-colors">
          <div class="card-body p-5">
            <.icon name="hero-arrow-trending-down" class="size-6 text-error mb-1" />
            <div class="font-bold">Expenses</div>
          </div>
        </.link>
        <.link href={~p"/finance/income"} class="card bg-base-100 border border-base-300 hover:border-primary transition-colors">
          <div class="card-body p-5">
            <.icon name="hero-arrow-trending-up" class="size-6 text-success mb-1" />
            <div class="font-bold">Income</div>
          </div>
        </.link>
        <.link href={~p"/finance/vendors"} class="card bg-base-100 border border-base-300 hover:border-primary transition-colors">
          <div class="card-body p-5">
            <.icon name="hero-building-storefront" class="size-6 text-primary mb-1" />
            <div class="font-bold">Vendors</div>
          </div>
        </.link>
        <.link href={~p"/finance/attachments"} class="card bg-base-100 border border-base-300 hover:border-primary transition-colors">
          <div class="card-body p-5">
            <.icon name="hero-paper-clip" class="size-6 text-primary mb-1" />
            <div class="font-bold">Receipts</div>
          </div>
        </.link>
      </div>
    </div>
    """
  end

  defp year_range do
    current = Date.utc_today().year
    Enum.to_list((current - 5)..current) |> Enum.reverse()
  end

  defp format_money(%Decimal{} = d), do: d |> Decimal.round(2) |> Decimal.to_string(:normal)
  defp format_money(_), do: "0.00"
end
