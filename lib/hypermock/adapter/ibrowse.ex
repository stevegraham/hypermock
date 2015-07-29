defmodule HyperMock.Adapter.IBrowse do
  alias HyperMock.Adapter
  alias HyperMock.Request
  alias HyperMock.Registry
  alias HyperMock.NetConnectNotAllowedError

  def target_module, do: :ibrowse

  def request_functions do
    [ {:send_req, &implementation([&1,&2,&3])},
      {:send_req, &implementation([&1,&2,&3,&4])},
      {:send_req, &implementation([&1,&2,&3,&4,&5])},
      {:send_req, &implementation([&1,&2,&3,&4,&5,&6])} ]
  end

  def implementation(args) do
    request = Registry.get(request_for(args))

    if request do
      request |> Tuple.to_list |> Enum.fetch!(1) |> to_response
    else
      raise NetConnectNotAllowedError, request_for(args)
    end
  end

  defp request_for(args) do
    struct %Request{}, Enum.zip([:uri, :headers, :method, :body], normalize(args))
  end

  defp normalize([url, headers, method]) do
    [to_string(url), normalize_headers(headers), method]
  end

  defp normalize([url, headers, method, body]) do
    normalize([url, headers, method]) ++ [to_string(body)]
  end

  defp normalize([url, headers, method, body, _options]) do
    normalize([url, headers, method, body])
  end

  defp normalize([url, headers, method, body, _options, _timeout]) do
    normalize([url, headers, method, body])
  end

  defp normalize_headers(header_list) do
    header_list |> Enum.map(fn({header, value}) -> { List.to_atom(header), to_string(value) } end)
  end

  defp denormalize_headers(header_list) do
    header_list |> Enum.map(fn({header, value}) -> { to_char_list(header), to_char_list(value) } end)
  end

  defp to_response(response) do
    { :ok, to_char_list(response.status), denormalize_headers(response.headers), to_char_list(response.body) }
  end
end
