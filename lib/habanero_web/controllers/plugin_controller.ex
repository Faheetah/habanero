defmodule HabaneroWeb.PluginController do
  @moduledoc """
  API controller for managing plugins
  """

  use HabaneroWeb, :controller

  @doc "Reloads all modules from disk"
  def reload(conn, _params) do
    Habanero.Loader.reload_modules()
    json(conn, %{"state" => "reloaded"})
  end

  @doc "Recompiles all modules in plugins folder"
  def recompile(conn, _params) do
    case Habanero.Loader.compile_modules() do
      {:error, msg} -> json(conn, %{"error" => msg})
      {:ok} -> json(conn, %{"state" => "recompiled"})
    end
  end
end
