defmodule TallyWeb.Livestock.AnimalDetailLive do
  use TallyWeb, :live_view

  alias Tally.{Livestock, Events, Finance}

  def mount(%{"id" => id}, _session, socket) do
    animal = Livestock.get_animal!(id)
    pedigree = Livestock.pedigree(animal)
    offspring = Livestock.list_offspring(animal)
    events = Events.list_events_for_animal(animal.id)
    finance_summary = Finance.animal_finance_summary(animal.id)
    recent_expenses = Finance.list_expenses_for_animal(animal.id) |> Enum.take(5)
    recent_incomes = Finance.list_incomes_for_animal(animal.id) |> Enum.take(5)

    {:ok,
     socket
     |> assign(:page_title, animal.tag)
     |> assign(:animal, animal)
     |> assign(:pedigree, pedigree)
     |> assign(:offspring, offspring)
     |> assign(:events, events)
     |> assign(:finance_summary, finance_summary)
     |> assign(:recent_expenses, recent_expenses)
     |> assign(:recent_incomes, recent_incomes)}
  end

  def render(assigns) do
    ~H"""
    <div class="space-y-6 max-w-5xl">
      <%!-- Breadcrumb --%>
      <div class="breadcrumbs text-sm">
        <ul>
          <li><.link href={~p"/livestock"}>Animals</.link></li>
          <li>{@animal.tag}</li>
        </ul>
      </div>

      <%!-- Hero Section --%>
      <div class="card bg-base-100 border border-base-300">
        <div class="card-body p-6">
          <div class="flex items-start gap-6">
            <div class="w-24 h-24 rounded-2xl bg-base-200 flex items-center justify-center shrink-0 overflow-hidden">
              <img :if={@animal.thumbnail_path} src={@animal.thumbnail_path} class="w-full h-full object-cover" />
              <.icon :if={!@animal.thumbnail_path} name="hero-photo" class="size-10 text-base-content/30" />
            </div>
            <div class="flex-1 min-w-0">
              <div class="flex items-start justify-between gap-4">
                <div>
                  <h1 class="text-2xl font-bold">{@animal.tag}</h1>
                  <p :if={@animal.name} class="text-base-content/60">{@animal.name}</p>
                </div>
                <div class="flex gap-2 shrink-0">
                  <span class={["badge", status_badge(@animal.status)]}>{@animal.status}</span>
                  <.link href={~p"/livestock/#{@animal.id}/edit"} class="btn btn-ghost btn-sm">
                    <.icon name="hero-pencil" class="size-4" />
                  </.link>
                </div>
              </div>
              <div class="flex flex-wrap gap-4 mt-3 text-sm text-base-content/70">
                <span><strong>Kind:</strong> {String.capitalize(@animal.kind)}</span>
                <span><strong>Sex:</strong> {String.capitalize(@animal.sex)}</span>
                <span :if={@animal.breed}><strong>Breed:</strong> {@animal.breed.name}</span>
                <span :if={@animal.dob}><strong>DOB:</strong> {Calendar.strftime(@animal.dob, "%b %d, %Y")}</span>
                <span><strong>Owned:</strong> {if @animal.owned, do: "Yes", else: "No"}</span>
              </div>
              <p :if={@animal.notes} class="mt-2 text-sm text-base-content/60">{@animal.notes}</p>
            </div>
          </div>
        </div>
      </div>

      <%!-- Finance Summary --%>
      <div class="grid grid-cols-3 gap-4">
        <div class="stat bg-base-100 border border-base-300 rounded-box">
          <div class="stat-title">Income</div>
          <div class="stat-value text-success text-xl">${format_money(@finance_summary.total_income)}</div>
        </div>
        <div class="stat bg-base-100 border border-base-300 rounded-box">
          <div class="stat-title">Expenses</div>
          <div class="stat-value text-error text-xl">${format_money(@finance_summary.total_expenses)}</div>
        </div>
        <div class="stat bg-base-100 border border-base-300 rounded-box">
          <div class="stat-title">Net</div>
          <div class={["stat-value text-xl", if(Decimal.compare(@finance_summary.net, 0) != :lt, do: "text-success", else: "text-error")]}>${format_money(@finance_summary.net)}</div>
        </div>
      </div>

      <%!-- Pedigree --%>
      <div class="card bg-base-100 border border-base-300">
        <div class="card-body p-6">
          <h2 class="font-bold text-lg mb-4">Pedigree</h2>
          <.pedigree_chart pedigree={@pedigree} />
        </div>
      </div>

      <%!-- Events Timeline --%>
      <div class="card bg-base-100 border border-base-300">
        <div class="card-body p-6">
          <h2 class="font-bold text-lg mb-4">Events</h2>
          <div :if={@events == []} class="text-base-content/50 text-sm">No events recorded.</div>
          <div class="space-y-2">
            <div :for={event <- @events} class="flex items-start gap-3 py-2 border-b border-base-200 last:border-0">
              <div class="badge badge-outline badge-sm mt-0.5 shrink-0">{event.event_type.name}</div>
              <div class="flex-1 min-w-0">
                <div class="text-sm">{event.description}</div>
                <div class="text-xs text-base-content/50 mt-0.5">{Calendar.strftime(event.happened_on, "%b %d, %Y")}</div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <%!-- Offspring --%>
      <div :if={@offspring != []} class="card bg-base-100 border border-base-300">
        <div class="card-body p-6">
          <h2 class="font-bold text-lg mb-4">Offspring ({length(@offspring)})</h2>
          <div class="grid grid-cols-2 sm:grid-cols-3 gap-2">
            <.link :for={o <- @offspring} href={~p"/livestock/#{o.id}"} class="btn btn-ghost btn-sm justify-start">
              {o.tag}{if o.name, do: " — #{o.name}", else: ""}
            </.link>
          </div>
        </div>
      </div>
    </div>
    """
  end

  attr :pedigree, :map, required: true

  defp pedigree_chart(assigns) do
    ~H"""
    <div class="overflow-x-auto">
      <div class="flex gap-2 min-w-max text-xs">
        <%!-- Gen 1: Subject --%>
        <div class="flex flex-col justify-center">
          <.ped_box animal={@pedigree.subject} gen={1} />
        </div>

        <%!-- Gen 2: Parents --%>
        <div class="flex flex-col justify-around gap-2">
          <.ped_box :if={@pedigree.sire} animal={@pedigree.sire.animal} gen={2} label="Sire" />
          <.ped_box :if={!@pedigree.sire} animal={nil} gen={2} label="Sire" />
          <.ped_box :if={@pedigree.dam} animal={@pedigree.dam.animal} gen={2} label="Dam" />
          <.ped_box :if={!@pedigree.dam} animal={nil} gen={2} label="Dam" />
        </div>

        <%!-- Gen 3: Grandparents --%>
        <div class="flex flex-col justify-around gap-1">
          <.ped_box animal={@pedigree.sire && @pedigree.sire.sire && @pedigree.sire.sire.animal} gen={3} label="Pat. Sire" />
          <.ped_box animal={@pedigree.sire && @pedigree.sire.dam && @pedigree.sire.dam.animal} gen={3} label="Pat. Dam" />
          <.ped_box animal={@pedigree.dam && @pedigree.dam.sire && @pedigree.dam.sire.animal} gen={3} label="Mat. Sire" />
          <.ped_box animal={@pedigree.dam && @pedigree.dam.dam && @pedigree.dam.dam.animal} gen={3} label="Mat. Dam" />
        </div>
      </div>
    </div>
    """
  end

  attr :animal, :any, default: nil
  attr :gen, :integer, required: true
  attr :label, :string, default: nil

  defp ped_box(assigns) do
    ~H"""
    <div class={["border rounded-lg p-2 w-32", if(@animal, do: "border-base-300 bg-base-100", else: "border-dashed border-base-300 bg-base-200/50")]}>
      <div :if={@label} class="text-base-content/40 text-xs mb-0.5">{@label}</div>
      <div :if={@animal} class="font-semibold truncate">
        <.link href={~p"/livestock/#{@animal.id}"} class="hover:text-primary">{@animal.tag}</.link>
      </div>
      <div :if={@animal && @animal.name} class="text-base-content/60 truncate">{@animal.name}</div>
      <div :if={!@animal} class="text-base-content/30 italic">Unknown</div>
    </div>
    """
  end

  defp status_badge("active"), do: "badge-success"
  defp status_badge("sold"), do: "badge-info"
  defp status_badge("deceased"), do: "badge-error"
  defp status_badge("retired"), do: "badge-warning"
  defp status_badge(_), do: "badge-ghost"

  defp format_money(%Decimal{} = d) do
    d |> Decimal.round(2) |> Decimal.to_string(:normal)
  end
  defp format_money(_), do: "0.00"
end
