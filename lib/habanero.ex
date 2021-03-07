defmodule Habanero do
  @moduledoc """
  High level functions for managing the Habanero stack

  Most of the functionality duplicates the Erlang init module, to provide more extensability
  http://erlang.org/doc/man/init.html
  """

  @doc "Stop the Habanero instance"
  def stop(), do: :init.stop()

  @doc "Restart the Habanero instance"
  def restart(), do: :init.restart()
end
