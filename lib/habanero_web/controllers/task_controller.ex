defmodule HabaneroWeb.TaskController do
  @moduledoc """
  API controller for running tasks
  """

  use HabaneroWeb, :controller

  # needs validator and to support post params for args
  @doc "Runs a module with given method, returns a `Habanero.Modules.Module` struct"
  def run(conn, %{"module" => module, "method" => method}) do
    json(conn, Habanero.Loader.run_module(module, method))
  end
end
