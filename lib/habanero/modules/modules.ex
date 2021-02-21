defmodule Habanero.Modules do
  @moduledoc """
  Built in modules registry
  """
  alias Habanero.Modules

  def get_modules() do
    [
      Modules.Debug,
      Modules.Timer
    ]
  end
end
