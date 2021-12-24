defmodule Environment do
  @moduledoc """
  Environment name and value storage.
  """

  @initial_environment %{
    "parent_env" => nil,
    "null" => nil,
    "true" => true,
    "false" => false,
    "VERSION" => "0.1"
  }

  @doc """
  The global variables always defined at the start of the program.
  """
  @spec global() :: pid()
  def global() do
    {:ok, pid} = Agent.start_link(fn -> @initial_environment end)
    pid
  end

  @doc """
  Creates a new environment process.
  `parent` is an optional environment pid. The child environment can look up any
  variables that are defined in the parent.
  """
  @spec start_link(pid() | nil) :: pid()
  def start_link(parent \\ nil) do
    {:ok, pid} = Agent.start_link(fn -> %{"parent_env" => parent} end)
    pid
  end

  @doc """
  Creates a variable with the given name and value.

  ## Examples
      iex> pid = Environment.start_link()
      iex> Environment.define(pid, "x", 4)
      4
  """
  @spec define(pid(), String.t(), any()) :: any()
  def define(pid, name, value) do
    Agent.update(pid, fn state -> Map.put(state, name, value) end)

    lookup(pid, name)
  end

  @doc """
  Returns a variable value if it exists or raises an error.

  ## Examples
      iex> pid = Environment.start_link()
      iex> Environment.define(pid, "x", 10)
      10
      iex> Environment.lookup(pid, "x")
      10
  """
  @spec lookup(pid(), any()) :: any() | :undefined
  def lookup(pid, name) do
    result = Agent.get(pid, fn state -> Map.fetch(state, name) end)

    case result do
      {:ok, value} -> value
      _ ->
        Agent.get(pid, fn state -> Map.get(state, "parent_env") end)
        |> resolve(name)
    end
  end

  defp resolve(nil, _), do: :undefined

  defp resolve(pid, name), do: lookup(pid, name)
end
