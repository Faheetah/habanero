defmodule Habanero.Loader do
  require Logger

  @plugin_path Application.get_env(:habanero, Habanero)[:plugins_path]

  def load_module(path, module) do
    Code.append_path(path)
    :code.load_file(module)
  end

  def load_modules_from_path() do
    @plugin_path
    |> load_modules_from_path
  end

  def load_modules_from_path(path) do
    true = Code.append_path(path)

    path
    |> Path.join("*.beam")
    |> Path.wildcard()
    |> Enum.map(fn file ->
      file
      |> Path.basename(".beam")
      |> String.to_atom()
    end)
    |> Enum.map(fn module ->
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
    end)
  end

  def unload_module(module) do
    :code.purge(module)
  end

  def call_module(module, method) do
    apply(String.to_existing_atom(module), method, [])
  end

  def start_modules() do
    modules = load_modules_from_path()
    opts = [strategy: :one_for_one, name: Habanero.Loader.Supervisor]
    Supervisor.start_link(modules, opts)
    modules
  end

  def restart_modules() do
    modules = load_modules_from_path()
    Supervisor.stop(Habanero.Loader.Supervisor)
    start_modules()
    modules
  end

  def compile_modules() do
    System.cmd("elixirc", ["."], cd: @plugin_path)
  end
end
