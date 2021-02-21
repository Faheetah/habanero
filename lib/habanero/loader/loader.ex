defmodule Habanero.Loader do
  require Logger

  def append_module_path(path) do
    true = Code.append_path(path)
  end

  def load_modules_by_path(path) do
    Habanero.Loader.get_modules_by_path(@plugin_path)
    |> Enum.each(&Habanero.Loader.load_module/1)
  end

  def get_modules_by_path(path) do
    path
    |> Path.join("*.beam")
    |> Path.wildcard()
    |> Enum.map(fn file ->
      file
      |> Path.basename(".beam")
      |> String.to_atom()
    end)
  end

  def load_module(module) do
    Logger.info("Loading module #{module}")
    :code.purge(module)
    :code.delete(module)

    :code.load_file(module)
    |> case do
      {:module, _} -> Logger.info("Successfully loaded #{module}")
      {:error, :badfile} -> Logger.error("Module could not be loaded: #{module}")
      _ -> Logger.error("An unknown error happened while loading #{module}")
    end

    module
  end

  @doc "Ensure module does not collide with the Habanero namespace"
  def validate_module(module) do
    module
    # if module name starts with Habanero, throw error
    # {:ok, module}
    {:error, "Module name must not collide with any currently imported modules"}
  end
end
