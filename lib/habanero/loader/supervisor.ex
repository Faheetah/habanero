defmodule Habanero.Loader.Supervisor do
  @moduledoc """
  Supervisor tree for all modules, including external modules loaded from plugin path
  """

  # @todo More logic should be shed out of here to Loader and Loader.Starter, make this file only concerned with supervising

  use DynamicSupervisor
  require Logger

  @plugin_path Application.get_env(:habanero, Habanero) |> Keyword.get(:plugin_path)

  def get_plugin_path() do
    @plugin_path
  end

  @doc false
  def start_link(_args) do
    DynamicSupervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @doc false
  def init(:ok) do
    Habanero.Loader.append_module_path(@plugin_path)
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  @doc "Starts all internal and external modules as an initialization task"
  def start_children() do
    (Habanero.Modules.get_modules() ++ Habanero.Loader.get_modules_by_path(@plugin_path))
    |> start_modules()
  end

  @doc "Starts modules given a list of modules"
  def start_modules(modules) do
    Enum.each(modules, fn module ->
      Habanero.Loader.load_module(module)

      DynamicSupervisor.start_child(__MODULE__, module)
      |> case do
        {:ok, pid} ->
          Logger.info("Started #{module} on #{inspect(pid)}")

        {:error, {:already_started, pid}} ->
          Logger.warning(
            "Module conflict: #{module} already started and running on #{inspect(pid)}"
          )

        msg ->
          Logger.error("An unexpected error occurred: #{inspect(msg)}")
      end
    end)
  end

  @doc "Unloads all external modules and starts any found modules, terminating any removed modules"
  def reload_modules() do
    DynamicSupervisor.which_children(__MODULE__)
    |> Enum.filter(fn {_, _, _, [module]} ->
      !Enum.member?(Habanero.Modules.get_modules(), module)
    end)
    |> Enum.map(fn {:undefined, pid, _type, [module]} ->
      Logger.info("Terminating #{module}")
      DynamicSupervisor.terminate_child(__MODULE__, pid)
      Habanero.Loader.unload_module(module)
      module
    end)
    |> start_modules()
  end

  @doc "validate that the module can spawn a genserver and respond as expected"
  def validate_plugin() do
  end

  @doc "get the config for initializing plugins from the application"
  def get_plugin_config() do
    # not sure yet what the configuration would look like, yaml?
    # for now probably just assume it's plain yaml files that are sitting in config/ or something
  end
end
