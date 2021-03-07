defmodule Habanero.Cluster do
  @moduledoc """
  Cluster functionality
  """

  def status(), do: [Node.self] ++ Node.list()

  def available(), do: Node.list(:known)

  @doc "Start a cluster using the local hostname"
  def start() do
    start(:habanero)
  end

  def start(name) when is_bitstring(name) do
    start(String.to_atom(name))
  end

  @doc """
  Start a cluster using habanero@HOSTNAME, iterating if the name is taken
  This action is idempotent, if a cluster is already started it will noop
  """
  def start(name) do
    case Node.start(name, :shortnames) do
      # Idempotence
      {:error, {:already_started, pid}} ->
        {:ok, "Already started #{name} on #{inspect pid}"}

      {:ok, pid} ->
        {:ok, "Node #{name} started on #{inspect pid}"}

      # Likely a name collision, prompt for a custom name
      _ ->
        {:ok, hostname} = :inet.gethostname
        {:error, "Node name #{name} already started on #{hostname}, please specify a name with Habanero.Cluster.start(name)"}

    end
  end

  @doc "Join an existing cluster"
  def join(name) when is_bitstring(name) do
    join(String.to_atom(name))
  end

  def join(name) do
    Node.connect(name)
  end

  @doc "Leave a cluster"
  def leave(), do: Node.stop()
end
