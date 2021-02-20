defmodule Foo do
  use GenServer
  require Logger

  def start_link(_args) do
    GenServer.start_link(
      __MODULE__,
      [
        {:log_limit, 1_000_000},
        {:count, 1}
      ],
      name: __MODULE__
    )
  end

  def init(args) do
    Logger.info("Foo task started")
    {:ok, args}
  end

  def handle_call({:run}, _from, state) do
    count = state[:count]
    Keyword.replace(state, :count, state[:count] + 1)
    {:reply, count, Keyword.replace(state, :count, count + 2)}
  end
end
