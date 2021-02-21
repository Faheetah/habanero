defmodule HabaneroWeb.PluginController do
  @moduledoc """
  API controller for managing plugins
  """

  use HabaneroWeb, :controller

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
end
