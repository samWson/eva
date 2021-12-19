defmodule Environment do
  @moduledoc """
  Environment name and value storage.
  """

  @initial_environment %{
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
  """
  @spec start_link() :: pid()
  def start_link() do
    {:ok, pid} = Agent.start_link(fn -> %{} end)
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
  @spec lookup(pid(), any()) :: any()
  def lookup(pid, name) do
    result = Agent.get(pid, fn state -> Map.fetch(state, name) end)

    case result do
      {:ok, value} -> value
      _ -> raise "ReferenceError: Variable '#{inspect(name)}' is not defined."
    end
  end
end
