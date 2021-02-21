defmodule Habanero.Modules.Debug do
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

  def handle_call({:run}, _from, state) do
    Logger.info("#{__MODULE__} called")
    {:reply, __MODULE__, state}
  end
end
