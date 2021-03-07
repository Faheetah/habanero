defmodule Habanero.Loader do
  @moduledoc "Handles loading and unloading of external modules"

  require Logger

  @doc "Add the given path to the Elixir library search path"
  def append_module_path(nil) do
    Logger.warn("No external plugin path given, skipping")
  end

  def append_module_path(path) do
    true = Code.append_path(path)
  end

  @doc "Get a list of modules for a given path with the .beam extension, converting to module names"
  def get_modules_by_path(nil), do: []

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

  @doc "Unloads a module and purges it from BEAM"
  def unload_module(module) do
    :code.purge(module)
    :code.delete(module)
  end

  @doc "Loads a module into BEAM"
  def load_module(module) do
    :code.load_file(module)
    |> case do
      {:module, _} -> Logger.info("Successfully loaded #{module}")
      {:error, :badfile} -> Logger.warning("Module could not be loaded: #{module}")
      msg -> Logger.error("An unknown error happened while loading #{module}: #{inspect(msg)}")
    end

    module
  end

  @doc "Ensure module does not collide with the Habanero namespace"
  def validate_module(module) do
    case !:erlang.function_exported(module, :module_info, 0) do
      false ->
        Logger.warning("Attempted to load a duplicated module: #{module}")
        false

      true ->
        true
    end
  end

  @doc "Runs a module from a given string, converting snake case to proper camel case and append Elixir."
  def run_module(module, method) do
    case to_existing_atom(module) do
      {:ok, mod} ->
        try do
          Habanero.Modules.result(
            mod
            |> GenServer.call({String.to_existing_atom(method)})
            |> Map.put(:module, Macro.underscore(mod))
            |> Map.put(:method, method)
          )
        rescue
          _error in [Protocol.UndefinedError, BadMapError, KeyError] ->
            Logger.error(
              "Module #{mod} does not confirm to module standards, expects a %Modules{} struct"
            )

            Habanero.Modules.error(
              module,
              method,
              "Module raised an unexpected error when returning output"
            )
          ArgumentError ->
            Habanero.Modules.error(
              module,
              method,
              "Invalid method: #{method}"
            )
        catch
          :exit, {:noproc, _} ->
            Habanero.Modules.error(module, method, "Module not found")
        end

      {:error, msg} ->
        Habanero.Modules.error(module, method, msg)
    end
  end

  @doc "Removes beam files at a given path"
  def delete_beam_files(plugin_path) do
    Path.join(plugin_path, "*.beam")
    |> Path.wildcard()
    |> Enum.each(&File.rm/1)
  end

  @doc "Compiles any source files found in the configured plugin path"
  def compile_modules() do
    plugin_path = Habanero.Loader.Supervisor.get_plugin_path()
    Logger.info("Recompiling modules in #{plugin_path}")
    {stdout, rc} = System.cmd("elixirc", ["."], cd: plugin_path)

    cond do
      rc > 0 ->
        Logger.error(stdout)
        {:error, stdout}

      true ->
        {:ok}
    end
  end

  def reload_modules() do
    Habanero.Loader.Supervisor.reload_modules()
  end

  defp to_existing_atom(module) do
    module =
      module
      |> String.split(".")
      |> Enum.map(&Macro.camelize/1)

    try do
      {:ok, Module.safe_concat(module)}
    rescue
      ArgumentError -> {:error, "No module found: #{module}"}
    end
  end
end
