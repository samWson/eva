defmodule Eva do
  @moduledoc """
  Eva interpreter.
  """

  @doc """
  Evaluates Eva source code.

  ## Examples

      iex> Eva.eval(1)
      1
  """
  def eval(exp) do
    cond do
      is_number(exp) ->
        exp

      true ->
        raise "Unimplemented"
    end
  end
end
