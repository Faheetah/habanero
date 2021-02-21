defmodule Bar do
  use GenServer
  require Logger

  @increment_by 11

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
    Logger.info("#{__MODULE__} task started")
    {:ok, args}
  end

  def handle_call({:run}, _from, state) do
    count = state[:count]
    Keyword.replace(state, :count, state[:count] + 1)
    {:reply, "#{__MODULE__}: #{count}", Keyword.replace(state, :count, count + @increment_by)}
  end
end
