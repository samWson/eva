defmodule Eva do
  @moduledoc """
  Eva interpreter.
  """

  @doc """
  Evaluates Eva source code.

  ## Examples

      iex> Eva.eval(["+", 5, 1])
      6
  """
  def eval(exp) do
    cond do
      is_number(exp) ->
        exp

      is_string(exp) ->
        String.slice(exp, 1..-2)

      is_list(exp) ->
        case exp do
          ["+" | tail] ->
            hd(tail) + Enum.at(tail, -1)

          _ ->
            raise "Unimplemented"
        end

      true ->
        raise "Unimplemented"
    end
  end

  defp is_string(exp) do
    is_binary(exp) &&
      String.starts_with?(exp, "\"") &&
      String.ends_with?(exp, "\"")
  end
end
