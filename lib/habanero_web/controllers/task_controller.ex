defmodule HabaneroWeb.TaskController do
  use HabaneroWeb, :controller

  # needs validator and to support post params for args
  def run(conn, %{"module" => module}) do
    module
    |> String.downcase()
    |> to_existing_atom()
    |> case do
      {:ok, module} ->
        json(conn, %{"call" => GenServer.call(module, {:run})})

      {:error, msg} ->
        json(conn, %{"error" => msg})
    end
  end

  defp to_existing_atom(module) do
    try do
      {:ok, String.to_existing_atom("Elixir." <> Macro.camelize(module))}
    rescue
      ArgumentError -> {:error, "No module found: #{module}"}
    end
  end
end
