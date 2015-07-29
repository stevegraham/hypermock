defmodule HyperMock.Request do
  defstruct method: :get, uri: "http://example.com/", headers: [], body: ""
end

defmodule HyperMock.Response do
  defstruct body: "", status: 200, headers: []
end

defmodule HyperMock.NetConnectNotAllowedError do
  defexception [:message]

  def exception(value) do
    message = """
    Real HTTP connections are disabled.

    Unregistered request: #{value.method |> to_string |> String.upcase} #{value.uri} with headers #{value.headers |> inspect} and body #{value.body |> inspect}

    You can stub this request with the following snippet:

    stub_request(#{value |> inspect})
    """

    %__MODULE__{ message: message }
  end
end

defmodule HyperMock.UnmetExpectationError do
  defexception [:message]

  def exception(value) do
    message = """
    The following requests were stubbed but not made:

    #{value |> Enum.map_join("\n", &inspect(&1))}

    If you're not using this stub, remove it to keep your tests green and clean.
    """

    %__MODULE__{ message: message }
  end
end
