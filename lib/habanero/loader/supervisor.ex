defmodule Habanero.Loader.Supervisor do
  @moduledoc """
  Supervisor tree for all modules, including external modules loaded from plugin path
  """

  use DynamicSupervisor
  require Logger

  @plugin_path Application.get_env(:habanero, Habanero)[:plugin_path]

  def start_link(_args) do
    DynamicSupervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    Habanero.Loader.append_module_path(@plugin_path)
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  @doc "Starts the supervisor tree for all modules"
  def start_children() do
    internal_modules = Habanero.Modules.get_modules()
    external_modules = Habanero.Loader.get_modules_by_path(@plugin_path)
    Enum.dedup(internal_modules ++ external_modules)
    |> Enum.each(fn module ->
      Habanero.Loader.load_module(module)
      DynamicSupervisor.start_child(__MODULE__, module)
    end)
  end

  def reload_modules() do
    DynamicSupervisor.which_children(__MODULE__)
    |> IO.inspect
    |> Enum.each(fn {:undefined, pid, _type, modules} ->
      Logger.info("Terminating #{hd(modules)}")
      DynamicSupervisor.terminate_child(__MODULE__, pid)
    end)
    start_children()
  end

  @doc "Compiles any source files found in the configured plugin path"
  def compile_modules() do
    System.cmd("elixirc", ["."], cd: @plugin_path)
  end

  def validate_plugin() do
    # validate that the module can spawn a genserver and respond as expected
  end

  def get_plugin_config() do
    # get the config for initializing plugins from the application
    # not sure yet what the configuration would look like, yaml?
    # for now probably just assume it's plain yaml files that are sitting in config/ or something
  end
end
