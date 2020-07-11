defmodule Download4pda.Downloads.TempLinks do
  @moduledoc """
  This module handles temporary links for various tasks.

  ## Examples

      iex> {:ok, _} = GenServer.start_link(TempLinks, name: :temp_links)

      iex> TempLinks.add("https://exapme.com/")
      "SOME_UUID_HERE"

      iex> TempLinks.get("")
      #Function...
  """
  use GenServer
  alias Download4pda.Downloads.TempLinks
  require Logger

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, name: :temp_links)
  end

  def init(_initial) do
    Process.send_after(self(), :tick, 1000)
    {:ok, %{}}
  end

  def add(url) do
    GenServer.call(:temp_links, {:add, url})
  end

  def get(uuid) do
    GenServer.call(:temp_links, {:get, uuid})
  end

  def handle_call({:add, url}, from, links) do
    headers = Application.fetch_env!(:download_4pda, :request_headers)
    options = Application.fetch_env!(:download_4pda, :request_options)

    uuid = UUID.uuid4()

    case Map.has_key?(links, uuid) do
      true ->
        TempLinks.handle_call({:add, url}, from, links)

      false ->
        {:reply, uuid,
         Map.put(
           links,
           uuid,
           {119,
            fn ->
              original_url = "https://4pda.ru" <> url

              Logger.info(
                "getting \"#{original_url}\" with following headers: \"#{inspect(headers)}\"
                and following options: \"#{inspect(options)}\""
              )

              {:ok, response} = HTTPoison.get(original_url, headers, options)
              {:ok, document} = Floki.parse_document(response.body)

              case List.first(Floki.find(document, ".dw-fdwlink > a")) do
                {_, attrs, _} ->
                  {_, url} = List.keyfind(attrs, "href", 0)
                  {:ok, HTTPoison.get!("https:" <> url, headers, stream_to: self(), async: :once)}

                nil ->
                  {:ok, HTTPoison.get!(original_url, headers, stream_to: self(), async: :once)}
              end
            end}
         )}
    end
  end

  def handle_call({:get, uuid}, _from, links) do
    case Map.get(links, uuid) do
      nil -> {:reply, {:error, :not_found}, links}
      {_, fun} -> {:reply, {:ok, fun}, links}
    end
  end

  def handle_info(:tick, links) do
    Process.send_after(self(), :tick, 1000)

    {:noreply,
     links
     |> Map.to_list()
     |> List.foldl(
       %{},
       fn x, acc ->
         case x do
           {_, {1, _}} -> acc
           {key, {time, url}} -> Map.put(acc, key, {time - 1, url})
         end
       end
     )}
  end
end
