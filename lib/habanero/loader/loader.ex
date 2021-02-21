defmodule Habanero.Loader do
  require Logger

  def append_module_path(path) do
    true = Code.append_path(path)
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
    |> Enum.filter(&validate_module/1)
  end

  def unload_module(module) do
    :code.purge(module)
    :code.delete(module)
  end

  def load_module(module) do
    :code.load_file(module)
    |> case do
      {:module, _} -> Logger.info("Successfully loaded #{module}")
      {:error, :badfile} -> Logger.warning("Module could not be loaded: #{module}")
      msg -> Logger.error("An unknown error happened while loading #{module}: #{inspect msg}")
    end

    module
  end

  @doc "Ensure module does not collide with the Habanero namespace"
  def validate_module(module) do
    case !:erlang.function_exported(module, :module_info, 0) do
      false ->
        Logger.warning("Attempted to load a duplicated module: #{module}")
        false
      true -> true
    end
  end
end
