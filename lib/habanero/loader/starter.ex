defmodule Habanero.Loader.Starter do
  @moduledoc """
  Light task to initiate starting children on application initialization
  """

  use Task
  require Logger

  def start_link(_args) do
    Task.start_link(Habanero.Loader.Supervisor, :start_children, [])
  end
end
