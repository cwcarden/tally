// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//
// If you have dependencies that try to import CSS, esbuild will generate a separate `app.css` file.
// To load it, simply add a second `<link>` to your `root.html.heex` file.

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html"
// Establish Phoenix Socket and LiveView configuration.
import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"
import {hooks as colocatedHooks} from "phoenix-colocated/tally"
import topbar from "../vendor/topbar"

// ── Sidebar persistence ───────────────────────────────────────────────────
const SIDEBAR_KEY = "tally:sidebar"

function updateSidebarClass() {
  const drawer = document.getElementById("main-drawer")
  const toggle = document.getElementById("drawer-toggle")
  if (!drawer || !toggle) return
  // Use localStorage as the source of truth. LiveView DOM morphing can reset
  // the checkbox to unchecked (server renders it without the checked attr),
  // so we always restore both the checkbox state and the drawer class here.
  const saved = localStorage.getItem(SIDEBAR_KEY)
  const wantOpen = saved !== null ? saved === "open" : window.innerWidth >= 1024
  toggle.checked = wantOpen
  if (wantOpen && window.innerWidth >= 1024) {
    drawer.classList.add("drawer-open")
  } else {
    drawer.classList.remove("drawer-open")
  }
}

function initSidebar() {
  const toggle = document.getElementById("drawer-toggle")
  if (!toggle) return

  // Set initial state from localStorage (or default based on viewport width)
  updateSidebarClass()

  // Avoid duplicate listeners across LiveView navigations
  if (toggle._sidebarBound) return
  toggle._sidebarBound = true

  toggle.addEventListener("change", () => {
    localStorage.setItem(SIDEBAR_KEY, toggle.checked ? "open" : "closed")
    updateSidebarClass()
  })
}

// Keep drawer-open class in sync when browser is resized
window.addEventListener("resize", updateSidebarClass)

// ─────────────────────────────────────────────────────────────────────────

const csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
const liveSocket = new LiveSocket("/live", Socket, {
  longPollFallbackMs: 2500,
  params: {_csrf_token: csrfToken},
  hooks: {...colocatedHooks},
})

// Show progress bar on live navigation and form submits
topbar.config({barColors: {0: "#29d"}, shadowColor: "rgba(0, 0, 0, .3)"})
window.addEventListener("phx:page-loading-start", _info => topbar.show(300))
window.addEventListener("phx:page-loading-stop", _info => {
  topbar.hide()
  initSidebar()
})

// Re-apply drawer-open after every LiveView DOM patch.
// LiveView morphs the DOM back to the server-rendered class list
// (removing any JS-added classes like drawer-open), so we need to
// restore the correct state after each patch — not just on navigation.
document.addEventListener("phx:update", updateSidebarClass)

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket

// Init sidebar on first load
document.addEventListener("DOMContentLoaded", initSidebar)

// The lines below enable quality of life phoenix_live_reload
// development features:
//
//     1. stream server logs to the browser console
//     2. click on elements to jump to their definitions in your code editor
//
if (process.env.NODE_ENV === "development") {
  window.addEventListener("phx:live_reload:attached", ({detail: reloader}) => {
    // Enable server log streaming to client.
    // Disable with reloader.disableServerLogs()
    reloader.enableServerLogs()

    // Open configured PLUG_EDITOR at file:line of the clicked element's HEEx component
    //
    //   * click with "c" key pressed to open at caller location
    //   * click with "d" key pressed to open at function component definition location
    let keyDown
    window.addEventListener("keydown", e => keyDown = e.key)
    window.addEventListener("keyup", _e => keyDown = null)
    window.addEventListener("click", e => {
      if(keyDown === "c"){
        e.preventDefault()
        e.stopImmediatePropagation()
        reloader.openEditorAtCaller(e.target)
      } else if(keyDown === "d"){
        e.preventDefault()
        e.stopImmediatePropagation()
        reloader.openEditorAtDef(e.target)
      }
    }, true)

    window.liveReloader = reloader
  })
}
