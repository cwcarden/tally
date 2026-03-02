defmodule TallyWeb.Finance.AttachmentsLive do
  use TallyWeb, :live_view

  alias Tally.Finance
  alias Tally.Uploads

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Receipts")
     |> assign(:attachments, Finance.list_unlinked_attachments())
     |> allow_upload(:receipt, accept: :any, max_entries: 5, max_file_size: 25_000_000)}
  end

  def handle_event("upload", _params, socket) do
    results =
      consume_uploaded_entries(socket, :receipt, fn %{path: tmp}, entry ->
        case Uploads.store_finance_attachment(tmp, entry) do
          {:ok, info} ->
            Finance.create_attachment(%{
              file_path: info.path,
              mime_type: info.mime,
              file_size: info.size,
              sha256: info.sha256
            })
          err -> err
        end
      end)

    count = Enum.count(results, &match?({:ok, _}, &1))
    {:noreply, socket
     |> put_flash(:info, "Uploaded #{count} file(s)")
     |> assign(:attachments, Finance.list_unlinked_attachments())}
  end

  def handle_event("noop", _params, socket), do: {:noreply, socket}

  def handle_event("delete_attachment", %{"id" => id}, socket) do
    att = Finance.get_attachment!(id)
    Uploads.delete_file(att.file_path)
    Finance.delete_attachment(att)
    {:noreply, socket |> put_flash(:info, "Deleted") |> assign(:attachments, Finance.list_unlinked_attachments())}
  end

  def render(assigns) do
    ~H"""
    <div class="space-y-4">
      <div class="flex items-center justify-between">
        <h1 class="text-2xl font-bold">Receipts</h1>
      </div>

      <div class="card bg-base-100 border border-base-300">
        <div class="card-body p-6">
          <h2 class="font-semibold mb-3">Upload Receipts</h2>
          <form phx-submit="upload" phx-change="noop" class="space-y-3">
            <.live_file_input upload={@uploads.receipt} class="file-input file-input-bordered w-full" />
            <button type="submit" class="btn btn-primary btn-sm">Upload</button>
          </form>
        </div>
      </div>

      <div class="card bg-base-100 border border-base-300">
        <div class="card-body p-4">
          <h2 class="font-semibold mb-3">Unlinked Receipts ({length(@attachments)})</h2>
          <div :if={@attachments == []} class="text-base-content/50 text-sm py-4 text-center">No unlinked receipts.</div>
          <div class="space-y-2">
            <div :for={att <- @attachments} class="flex items-center justify-between gap-3 py-2 border-b border-base-200 last:border-0">
              <div class="flex items-center gap-3 min-w-0">
                <.icon name="hero-paper-clip" class="size-4 shrink-0 text-base-content/40" />
                <div class="min-w-0">
                  <div class="text-sm font-medium truncate">{Path.basename(att.file_path)}</div>
                  <div class="text-xs text-base-content/50">{format_size(att.file_size)} · {att.mime_type}</div>
                </div>
              </div>
              <button class="btn btn-ghost btn-xs text-error shrink-0"
                phx-click="delete_attachment" phx-value-id={att.id}
                data-confirm="Delete this receipt?">
                <.icon name="hero-trash" class="size-3.5" />
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  defp format_size(nil), do: "unknown size"
  defp format_size(bytes) when bytes < 1024, do: "#{bytes} B"
  defp format_size(bytes) when bytes < 1_048_576, do: "#{Float.round(bytes / 1024, 1)} KB"
  defp format_size(bytes), do: "#{Float.round(bytes / 1_048_576, 1)} MB"
end
