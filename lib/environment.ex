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

  @type repository() :: map()

  @doc """
  The global variables always defined at the start of the program.
  """
  @spec global() :: map()
  def global() do
    @initial_environment
  end

  @doc """
  Creates a variable with the given name and value.

  ## Examples
  		iex> Environment.define(%{}, "x", 4)
  		{4, %{"x" => 4}}
  """
  @spec define(repository(), String.t(), any()) :: {any(), repository()}
  def define(env, name, value) do
    updated_env = Map.put(env, name, value)

    {updated_env[name], updated_env}
  end

  @doc """
  Returns a variable value if it exists or raises an error.

  ## Examples
      iex> Environment.lookup(%{"x" => 10}, "x")
      10
  """
  @spec lookup(repository(), any()) :: any()
  def lookup(env, name) do
    result = Map.fetch(env, name)

    case result do
      {:ok, value} -> value
      _ -> raise "ReferenceError: Variable '#{inspect(name)}' is not defined."
    end
  end
end
