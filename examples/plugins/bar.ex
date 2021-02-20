defmodule Bar do
  use GenServer
  require Logger

  def start_link(_args) do
    GenServer.start_link(
      __MODULE__,
      [
        {:log_limit, 1_000_000}
      ],
      name: __MODULE__
    )
  end

  def init(args) do
    Logger.info("Bar task started")
    {:ok, args}
  end

  def handle_call({:run}, _from, state) do
    Logger.info("Bar called")
    Logger.info(state)
    {:reply, :bar, state}
  end
end
