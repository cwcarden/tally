defmodule TallyWeb.DashboardLive do
  use TallyWeb, :live_view
  import Ecto.Query

  alias Tally.Finance

  def mount(_params, _session, socket) do
    year = Date.utc_today().year
    summary = Finance.ytd_summary(year)
    animal_count = Tally.Repo.aggregate(Tally.Livestock.Animal, :count)
    active_count = Tally.Repo.aggregate(from(a in Tally.Livestock.Animal, where: a.status == "active"), :count)

    {:ok,
     socket
     |> assign(:page_title, "Dashboard")
     |> assign(:summary, summary)
     |> assign(:animal_count, animal_count)
     |> assign(:active_count, active_count)}
  end

  def render(assigns) do
    ~H"""
    <div class="space-y-6">
      <div>
        <h1 class="text-2xl font-bold">Dashboard</h1>
        <p class="text-base-content/60 text-sm mt-1">{@summary.year} overview</p>
      </div>

      <%!-- YTD Finance Cards --%>
      <div class="grid grid-cols-1 sm:grid-cols-3 gap-4">
        <div class="card bg-base-100 border border-base-300 shadow-sm">
          <div class="card-body p-5">
            <div class="flex items-center justify-between">
              <span class="text-sm text-base-content/60">YTD Income</span>
              <.icon name="hero-arrow-trending-up" class="size-5 text-success" />
            </div>
            <div class="text-2xl font-bold text-success mt-1">
              ${format_money(@summary.total_income)}
            </div>
          </div>
        </div>

        <div class="card bg-base-100 border border-base-300 shadow-sm">
          <div class="card-body p-5">
            <div class="flex items-center justify-between">
              <span class="text-sm text-base-content/60">YTD Expenses</span>
              <.icon name="hero-arrow-trending-down" class="size-5 text-error" />
            </div>
            <div class="text-2xl font-bold text-error mt-1">
              ${format_money(@summary.total_expenses)}
            </div>
          </div>
        </div>

        <div class="card bg-base-100 border border-base-300 shadow-sm">
          <div class="card-body p-5">
            <div class="flex items-center justify-between">
              <span class="text-sm text-base-content/60">Net</span>
              <.icon name="hero-scale" class="size-5 text-primary" />
            </div>
            <div class={["text-2xl font-bold mt-1", if(Decimal.compare(@summary.net, 0) != :lt, do: "text-success", else: "text-error")]}>
              ${format_money(@summary.net)}
            </div>
          </div>
        </div>
      </div>

      <%!-- Quick Nav Cards --%>
      <div class="grid grid-cols-1 sm:grid-cols-3 gap-4">
        <.link href={~p"/livestock"} class="card bg-primary text-primary-content shadow-sm hover:opacity-90 transition-opacity">
          <div class="card-body p-5">
            <.icon name="hero-tag" class="size-7 mb-2" />
            <div class="text-lg font-bold">Livestock</div>
            <div class="text-sm opacity-80">{@animal_count} total · {@active_count} active</div>
          </div>
        </.link>

        <.link href={~p"/finance"} class="card bg-base-100 border border-base-300 shadow-sm hover:border-primary transition-colors">
          <div class="card-body p-5">
            <.icon name="hero-chart-bar" class="size-7 mb-2 text-primary" />
            <div class="text-lg font-bold">Finance</div>
            <div class="text-sm text-base-content/60">Expenses, income & vendors</div>
          </div>
        </.link>

        <.link href={~p"/settings/breeds"} class="card bg-base-100 border border-base-300 shadow-sm hover:border-primary transition-colors">
          <div class="card-body p-5">
            <.icon name="hero-cog-6-tooth" class="size-7 mb-2 text-primary" />
            <div class="text-lg font-bold">Settings</div>
            <div class="text-sm text-base-content/60">Breeds, event types & categories</div>
          </div>
        </.link>
      </div>
    </div>
    """
  end

  defp format_money(%Decimal{} = d) do
    d
    |> Decimal.round(2)
    |> Decimal.to_string(:normal)
    |> then(fn s ->
      [int_part | dec_parts] = String.split(s, ".")
      dec = List.first(dec_parts, "00") |> String.pad_trailing(2, "0")
      int_part
      |> String.graphemes()
      |> Enum.reverse()
      |> Enum.chunk_every(3)
      |> Enum.join(",")
      |> String.graphemes()
      |> Enum.reverse()
      |> Enum.join()
      |> then(&"#{&1}.#{dec}")
    end)
  end
  defp format_money(_), do: "0.00"
end
