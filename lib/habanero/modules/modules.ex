defmodule Habanero.Modules do
  @moduledoc """
  Built in modules registry
  """

  alias Habanero.Modules

  @enforce_keys [
    :method,
    :module,
    :status
  ]

  @derive Jason.Encoder
  defstruct [
    :method,
    :message,
    :module,
    :status
  ]

  def error(module, method, message) do
    %__MODULE__{module: module, method: method, message: message, status: :error}
  end

  @doc "Get the list of internal modules"
  def get_modules() do
    [
      Modules.Debug,
      Modules.Timer
    ]
  end
end
