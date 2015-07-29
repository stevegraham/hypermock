defmodule HyperMock do
  defmacro __using__(opts) do
    adapter = opts[:adapter] || HyperMock.Adapter.IBrowse

    quote do
      :application.start(unquote(adapter).target_module)
      @adapter unquote(adapter)
    end
  end

  def stub_request(request, response \\ %HyperMock.Response{}) do
    HyperMock.Registry.put request, response
  end

  def verify_expectations do
    unused_stubs = HyperMock.Registry.all
      |> Enum.filter_map(fn({_,_,count}) -> count == 0 end, fn({req,_,_}) -> req end)

    if Enum.any?(unused_stubs), do: raise(HyperMock.UnmetExpectationError, unused_stubs)
  end

  defmacro intercept(test) do
    quote do
      import unquote(__MODULE__)

      alias HyperMock.Request
      alias HyperMock.Response
      alias HyperMock.Registry

      for {fun, imp} <- @adapter.request_functions do
        :meck.expect(@adapter.target_module, fun, imp)
      end

      Registry.start_link

      try do
        unquote(test)

        verify_expectations
      after
        :meck.unload @adapter.target_module
        Registry.stop
      end
    end
  end
end
