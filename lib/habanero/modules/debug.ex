defmodule Habanero.Modules.Debug do
  use GenServer
  require Logger

  def start_link(_args) do
    GenServer.start_link(
      __MODULE__,
      [
        {:log_limit, 1_000_000}
      ],
      name: Debug
    )
  end

  def handle_call({:run}, _from, state) do
    {:reply, %{setatus: :ok, message: __MODULE__}, state}
  end
end
