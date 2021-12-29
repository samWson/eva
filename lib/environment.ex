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
  Returns a variable value if it exists or returns `:undefined` if it does not
  exist.

  ## Examples
      iex> pid = Environment.start_link()
      iex> Environment.define(pid, "x", 10)
      10
      iex> Environment.lookup(pid, "x")
      10
  """
  @spec lookup(pid(), any()) :: any() | :undefined
  def lookup(pid, name) do
    env = resolve(pid, name)

    case env do
      {:ok, pid} ->
        Agent.get(pid, fn state -> Map.get(state, name) end)
      _ ->
        :undefined
    end
  end

  @doc """
  Assigns to a variable and returns the value or returns `:undefined` if the
  variable does not exist.

  ## Examples
      iex> pid = Environment.start_link()
      iex> Environment.define(pid, "x", 10)
      10
      iex> Environment.assign(pid, "x", 100)
      100
      iex> Environment.lookup(pid, "x")
      100
  """
  @spec assign(pid(), String.t(), any()) :: any() | :undefined
  def assign(pid, name, value) do
    env = resolve(pid, name)

    case env do
      {:ok, pid} ->
        Agent.update(pid, fn state -> Map.put(state, name, value) end)
        value
      _ -> :undefined
    end
  end

  defp resolve(nil, _), do: :undefined

  defp resolve(pid, name) do
    has_key = Agent.get(pid, fn state -> Map.has_key?(state, name) end)

    if has_key do
      {:ok, pid}
    else
      parent = Agent.get(pid, fn state -> Map.get(state, "parent_env") end)
      resolve(parent, name)
    end
  end
end
