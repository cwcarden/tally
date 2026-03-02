defmodule Tally.Uploads do
  @moduledoc """
  Handles local filesystem uploads for animals (thumbnails, documents)
  and finance (receipt attachments).
  """

  @uploads_root "priv/static/uploads"

  @doc """
  Stores an uploaded file from a tmp path to a destination relative to @uploads_root.
  `entry` is the LiveView UploadEntry struct (for metadata).
  `tmp_path` is the path received in the `consume_uploaded_entries` callback.
  Returns `{:ok, %{path: web_path, mime: mime, size: size, sha256: sha256}}`.
  """
  def store_upload(tmp_path, entry, dest_rel) do
    dest_abs = Path.join([@uploads_root, dest_rel])
    dest_abs |> Path.dirname() |> File.mkdir_p!()

    with {:ok, data} <- File.read(tmp_path),
         :ok <- File.write(dest_abs, data) do
      {:ok, %{
        path: "/" <> Path.join(["uploads", dest_rel]),
        mime: entry.client_type,
        size: byte_size(data),
        sha256: sha256_hex(data)
      }}
    end
  end

  @doc """
  Stores a thumbnail for an animal.
  Called inside `consume_uploaded_entries(socket, :thumbnail, fn %{path: tmp}, entry -> ... end)`.
  """
  def store_thumbnail(tmp_path, entry, animal_id) do
    ext = entry.client_name |> Path.extname() |> String.downcase()
    dest_rel = "animals/#{animal_id}/thumbnail#{ext}"
    case store_upload(tmp_path, entry, dest_rel) do
      {:ok, %{path: path}} -> {:ok, path}
      err -> err
    end
  end

  @doc """
  Stores a document for an animal.
  Called inside `consume_uploaded_entries`.
  """
  def store_animal_document(tmp_path, entry, animal_id) do
    filename = sanitize_filename(entry.client_name)
    dest_rel = "animals/#{animal_id}/docs/#{unique_prefix()}_#{filename}"
    store_upload(tmp_path, entry, dest_rel)
  end

  @doc """
  Stores a finance receipt.
  Called inside `consume_uploaded_entries`.
  """
  def store_finance_attachment(tmp_path, entry) do
    {year, month, _} = Date.utc_today() |> Date.to_erl()
    filename = sanitize_filename(entry.client_name)
    dest_rel = "finance/#{year}/#{month |> Integer.to_string() |> String.pad_leading(2, "0")}/#{unique_prefix()}_#{filename}"
    store_upload(tmp_path, entry, dest_rel)
  end

  @doc """
  Deletes a file given its web path (e.g. "/uploads/animals/1/docs/file.pdf").
  """
  def delete_file(nil), do: :ok
  def delete_file(web_path) do
    abs_path = String.trim_leading(web_path, "/")
    abs_path = Path.join("priv/static", abs_path)
    case File.rm(abs_path) do
      :ok -> :ok
      {:error, :enoent} -> :ok
      err -> err
    end
  end

  defp sha256_hex(data) do
    :crypto.hash(:sha256, data) |> Base.encode16(case: :lower)
  end

  defp sanitize_filename(name) do
    name
    |> Path.basename()
    |> String.replace(~r/[^\w\.\-]/, "_")
  end

  defp unique_prefix do
    :crypto.strong_rand_bytes(6) |> Base.encode16(case: :lower)
  end
end
