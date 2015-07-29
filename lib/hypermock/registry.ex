defmodule HyperMock.Registry do
  def start_link do
    Agent.start_link fn -> [] end, name: __MODULE__
  end

  def stop do
    Agent.stop __MODULE__
  end

  def get(request) do
    Agent.get_and_update __MODULE__, &_process(&1, request)
  end

  def all do
    Agent.get __MODULE__, fn(state) -> state end
  end

  def put(request, response) do
    Agent.update __MODULE__, &[{request,response,0} | &1]
  end

  def _process(state, request) do
    tuple = Enum.find state, fn({req, _, _}) -> req == request end

    if tuple do
      {request, response, count } = tuple
      ret = {request, response, count + 1}
      new_state = (state -- [tuple]) ++ [ret]

      {ret, new_state}
    else
      {nil, state}
    end
  end
end
