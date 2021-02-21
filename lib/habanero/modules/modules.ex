defmodule Habanero.Modules do
  @moduledoc """
  Built in modules registry
  """

  alias Habanero.Modules.Builtin

  def error(module, method, message) do
    %Habanero.Modules.Module{module: module, method: method, message: message, status: :error}
  end

  def result(result) do
    struct!(Habanero.Modules.Module, result)
  end

  @doc "Get the list of internal modules"
  def get_modules() do
    [
      Builtin.Debug,
      Builtin.Timer
    ]
  end
end
