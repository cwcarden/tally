defmodule TallyWeb.Layouts do
  @moduledoc """
  Tally app layouts: root HTML skeleton and sidebar app layout.
  """
  use TallyWeb, :html

  embed_templates "layouts/*"

  attr :flash, :map, required: true
  attr :current_scope, :map, default: nil
  # When used as a LiveView layout, Phoenix passes rendered content as @inner_content.
  # When used as a slot-based component in controller templates, @inner_block is used.
  attr :inner_content, :any, default: nil
  slot :inner_block

  def app(assigns) do
    ~H"""
    <div class="drawer min-h-screen" id="main-drawer">
      <input id="drawer-toggle" type="checkbox" class="drawer-toggle" />

      <div class="drawer-content flex flex-col">
        <%!-- Top navbar — visible on all screen sizes --%>
        <div class="navbar bg-base-100 border-b border-base-300 px-4 sticky top-0 z-30">
          <div class="flex-none">
            <label for="drawer-toggle" class="btn btn-ghost btn-sm" aria-label="Toggle sidebar">
              <.icon name="hero-bars-3" class="size-5" />
            </label>
          </div>
          <div class="flex-1">
            <a href={~p"/dashboard"} class="btn btn-ghost btn-sm font-bold text-base gap-2 normal-case">
              <div class="bg-primary rounded-lg p-1">
                <.icon name="hero-calculator" class="size-3.5 text-primary-content" />
              </div>
              Tally
            </a>
          </div>
        </div>

        <main class="flex-1 p-4 md:p-6 lg:p-8">
          {if @inner_content != nil, do: @inner_content, else: render_slot(@inner_block)}
        </main>
      </div>

      <div class="drawer-side z-40">
        <label for="drawer-toggle" aria-label="close sidebar" class="drawer-overlay"></label>
        <aside class="bg-base-100 border-r border-base-300 w-64 min-h-full flex flex-col">
          <%!-- Sidebar brand --%>
          <div class="px-5 py-5 border-b border-base-300">
            <a href={~p"/dashboard"} class="flex items-center gap-3">
              <div class="bg-primary rounded-xl p-2">
                <.icon name="hero-calculator" class="size-5 text-primary-content" />
              </div>
              <div>
                <div class="font-bold text-lg leading-none">Tally</div>
                <div class="text-xs text-base-content/50 mt-0.5">Ranch Management</div>
              </div>
            </a>
          </div>

          <%!-- Nav items --%>
          <nav class="flex-1 px-3 py-4 space-y-0.5 overflow-y-auto">
            <.nav_item icon="hero-squares-2x2" label="Dashboard" href={~p"/dashboard"} />

            <div class="pt-4 pb-1">
              <p class="px-3 text-xs font-semibold text-base-content/40 uppercase tracking-wider">Livestock</p>
            </div>
            <.nav_item icon="hero-tag" label="Animals" href={~p"/livestock"} />

            <div class="pt-4 pb-1">
              <p class="px-3 text-xs font-semibold text-base-content/40 uppercase tracking-wider">Finance</p>
            </div>
            <.nav_item icon="hero-chart-bar" label="Overview" href={~p"/finance"} />
            <.nav_item icon="hero-arrow-trending-down" label="Expenses" href={~p"/finance/expenses"} />
            <.nav_item icon="hero-arrow-trending-up" label="Income" href={~p"/finance/income"} />
            <.nav_item icon="hero-building-storefront" label="Vendors" href={~p"/finance/vendors"} />
            <.nav_item icon="hero-paper-clip" label="Receipts" href={~p"/finance/attachments"} />

            <div class="pt-4 pb-1">
              <p class="px-3 text-xs font-semibold text-base-content/40 uppercase tracking-wider">Settings</p>
            </div>
            <.nav_item icon="hero-bookmark" label="Breeds" href={~p"/settings/breeds"} />
            <.nav_item icon="hero-calendar" label="Event Types" href={~p"/settings/event-types"} />
            <.nav_item icon="hero-rectangle-stack" label="Categories" href={~p"/settings/categories"} />
          </nav>

          <%!-- Footer: user + theme --%>
          <div class="border-t border-base-300 px-4 py-4 space-y-4">
            <div class="flex items-center justify-between gap-2">
              <div class="text-xs truncate text-base-content/60 min-w-0">
                {if @current_scope, do: @current_scope.user.email, else: ""}
              </div>
              <.link
                :if={@current_scope}
                href={~p"/users/log-out"}
                method="delete"
                class="btn btn-ghost btn-xs shrink-0"
                title="Log out"
              >
                <.icon name="hero-arrow-right-on-rectangle" class="size-4" />
              </.link>
            </div>
            <.theme_picker />
          </div>
        </aside>
      </div>
    </div>

    <.flash_group flash={@flash} />
    """
  end

  attr :icon, :string, required: true
  attr :label, :string, required: true
  attr :href, :string, required: true

  defp nav_item(assigns) do
    ~H"""
    <.link
      href={@href}
      class="flex items-center gap-3 px-3 py-2 rounded-lg text-sm font-medium text-base-content/70 hover:text-base-content hover:bg-base-200 transition-colors"
    >
      <.icon name={@icon} class="size-4 shrink-0" />
      {@label}
    </.link>
    """
  end

  attr :flash, :map, required: true
  attr :id, :string, default: "flash-group"

  def flash_group(assigns) do
    ~H"""
    <div id={@id} aria-live="polite">
      <.flash kind={:info} flash={@flash} />
      <.flash kind={:error} flash={@flash} />
      <.flash
        id="client-error"
        kind={:error}
        title={gettext("We can't find the internet")}
        phx-disconnected={show(".phx-client-error #client-error") |> JS.remove_attribute("hidden")}
        phx-connected={hide("#client-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        {gettext("Attempting to reconnect")}
        <.icon name="hero-arrow-path" class="ml-1 size-3 motion-safe:animate-spin" />
      </.flash>
      <.flash
        id="server-error"
        kind={:error}
        title={gettext("Something went wrong!")}
        phx-disconnected={show(".phx-server-error #server-error") |> JS.remove_attribute("hidden")}
        phx-connected={hide("#server-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        {gettext("Attempting to reconnect")}
        <.icon name="hero-arrow-path" class="ml-1 size-3 motion-safe:animate-spin" />
      </.flash>
    </div>
    """
  end

  @doc """
  Theme picker with school selector (Neutral / Red Raider / Aggie)
  and mode selector (System / Light / Dark).
  Active state is driven by `data-school` and `data-mode` attributes on <html>.
  """
  def theme_picker(assigns) do
    ~H"""
    <div class="space-y-2.5">
      <%!-- School selection --%>
      <div>
        <p class="text-xs text-base-content/40 mb-1.5 font-medium uppercase tracking-wider">School</p>
        <div class="flex gap-1">
          <button
            class={[
              "btn btn-xs flex-1 normal-case font-medium",
              "[[data-school=neutral]_&]:btn-primary"
            ]}
            phx-click={JS.dispatch("phx:set-school")}
            data-phx-school="neutral"
            title="Neutral (Amber)"
          >Neutral</button>
          <button
            class={[
              "btn btn-xs flex-1 normal-case font-medium",
              "[[data-school=red-raider]_&]:btn-primary"
            ]}
            phx-click={JS.dispatch("phx:set-school")}
            data-phx-school="red-raider"
            title="Texas Tech Red Raiders"
          >Tech</button>
          <button
            class={[
              "btn btn-xs flex-1 normal-case font-medium",
              "[[data-school=aggie]_&]:btn-primary"
            ]}
            phx-click={JS.dispatch("phx:set-school")}
            data-phx-school="aggie"
            title="Texas A&M Aggies"
          >A&M</button>
        </div>
      </div>

      <%!-- Mode selection: sliding pill --%>
      <div>
        <p class="text-xs text-base-content/40 mb-1.5 font-medium uppercase tracking-wider">Mode</p>
        <div class="relative flex flex-row items-center border border-base-300 bg-base-300 rounded-full">
          <div class={[
            "absolute w-1/3 h-full rounded-full border border-base-200 bg-base-100 brightness-110 transition-[left] duration-200",
            "[[data-mode=system]_&]:left-0",
            "[[data-mode=light]_&]:left-1/3",
            "[[data-mode=dark]_&]:left-2/3"
          ]} />
          <button
            class="flex items-center justify-center p-1.5 cursor-pointer w-1/3 z-10"
            phx-click={JS.dispatch("phx:set-mode")}
            data-phx-mode="system"
            title="System"
          >
            <.icon name="hero-computer-desktop-micro" class="size-3.5 opacity-75 hover:opacity-100" />
          </button>
          <button
            class="flex items-center justify-center p-1.5 cursor-pointer w-1/3 z-10"
            phx-click={JS.dispatch("phx:set-mode")}
            data-phx-mode="light"
            title="Light"
          >
            <.icon name="hero-sun-micro" class="size-3.5 opacity-75 hover:opacity-100" />
          </button>
          <button
            class="flex items-center justify-center p-1.5 cursor-pointer w-1/3 z-10"
            phx-click={JS.dispatch("phx:set-mode")}
            data-phx-mode="dark"
            title="Dark"
          >
            <.icon name="hero-moon-micro" class="size-3.5 opacity-75 hover:opacity-100" />
          </button>
        </div>
      </div>
    </div>
    """
  end
end
