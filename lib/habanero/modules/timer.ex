defmodule Habanero.Modules.Timer do
  use GenServer
  require Logger

  def start_link(_args) do
    GenServer.start_link(
      __MODULE__,
      [
        {:log_limit, 1_000_000}
      ],
      name: Timer
    )
  end

  def init(args) do
    Logger.info("#{__MODULE__} task started")
    {:ok, args}
  end

  def handle_call({:run}, _from, state) do
    Logger.info("#{__MODULE__} called")
    {:reply, %{status: :ok, message: __MODULE__}, state}
  end
end
