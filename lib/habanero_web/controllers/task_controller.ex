defmodule HabaneroWeb.TaskController do
  use HabaneroWeb, :controller

  # needs validator and to support post params for args
  def run(conn, %{"module" => module}) do
    module
    |> String.downcase()
    |> to_existing_atom()
    |> case do
      {:ok, mod} ->
        try do
          json(conn, %{"ok" => GenServer.call(mod, {:run})})
        catch
          :exit, {:noproc, _} -> json(conn, %{"error" => "Module not found: #{module}"})
        end

      {:error, msg} ->
        json(conn, %{"error" => msg})
    end
  end

  @doc "Reloads all modules from disk"
  def reload(conn, _params) do
    Habanero.Loader.Supervisor.reload_modules()
    json(conn, %{"state" => "reloaded"})
  end

  @doc "Recompiles all modules in plugins folder"
  def recompile(conn, _params) do
    Habanero.Loader.Supervisor.compile_modules()
    json(conn, %{"state" => "recompiled"})
  end
  defp to_existing_atom(module) do
    try do
      {:ok, String.to_existing_atom("Elixir." <> Macro.camelize(module))}
    rescue
      ArgumentError -> {:error, "No module found: #{module}"}
    end
  end
end
