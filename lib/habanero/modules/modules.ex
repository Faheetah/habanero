defmodule Habanero.Modules do
  @moduledoc """
  Built in modules registry
  """

  alias Habanero.Modules

  @doc "Get the list of internal modules"
  def get_modules() do
    [
      Modules.Debug,
      Modules.Timer
    ]
  end
end
