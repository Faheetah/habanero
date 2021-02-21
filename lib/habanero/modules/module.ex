defmodule Habanero.Modules.Module do
  @moduledoc """
  Struct to hold the status of a model execution.

  `:model` required
  `:method` required
  `:status` required
  `:message`
  """

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

  @type t :: %__MODULE__{
          method: atom(),
          message: term(),
          module: atom(),
          status: :ok | :error | :running | :noop
        }

end
