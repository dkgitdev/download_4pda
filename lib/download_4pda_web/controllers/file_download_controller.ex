defmodule Download4pdaWeb.FileDownloadController do
  use Download4pdaWeb, :controller

  alias Download4pda.Downloads.TempLinks

  action_fallback Download4pdaWeb.FallbackController

  defp async_download(conn, resp, download_fn) do
    resp_id = resp.id

    receive do
      %HTTPoison.AsyncStatus{code: status_code, id: ^resp_id} ->
        conn = Plug.Conn.put_status(conn, status_code)
        HTTPoison.stream_next(resp)
        download_fn.(conn, resp, download_fn)

      %HTTPoison.AsyncHeaders{headers: headers, id: ^resp_id} ->
        conn =
          List.foldl(headers, conn, fn header, conn ->
            {key, value} = header
            d_key = key |> String.downcase()

            if String.contains?(d_key, "cookie") || String.contains?(d_key, "content-length") do
              conn
            else
              Plug.Conn.put_resp_header(conn, key, value)
            end
          end)

        conn = Plug.Conn.send_chunked(conn, conn.status)
        HTTPoison.stream_next(resp)
        download_fn.(conn, resp, download_fn)

      %HTTPoison.AsyncChunk{chunk: chunk, id: ^resp_id} ->
        {:ok, conn} = Plug.Conn.chunk(conn, chunk)
        HTTPoison.stream_next(resp)
        download_fn.(conn, resp, download_fn)

      %HTTPoison.AsyncEnd{id: ^resp_id} ->
        conn
    end
  end

  def put_task(conn, %{"id" => id, "name" => name}) do
    uuid = TempLinks.add("/forum/dl/post/" <> Enum.join([id, name], "/"))

    conn
    |> assign(:uuid, uuid)
    |> render(:put_task)
  end

  def get_file(conn, %{"uuid" => uuid}) do
    with {:ok, get_page_stream} <- TempLinks.get(uuid),
         {:ok, stream_response} <- get_page_stream.() do
      async_download(conn, stream_response, &async_download/3)
    end
  end
end
