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
    {:ok, args}
  end

  def handle_call({:run}, _from, state) do
    count = state[:count]
    Keyword.replace(state, :count, state[:count] + 1)

    {
      :reply,
      %{module: __MODULE__, status: :ok, message: count},
      Keyword.replace(state, :count, count + @increment_by)
    }
  end
end
