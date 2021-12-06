defmodule Eva do
  @moduledoc """
  Eva interpreter.
  """

  require Environment

  @type expression() ::
          integer()
          | String.t()
          | list()
          | expression()

  @doc """
  Evaluates an expression in the given environment.

  ## Examples

      iex> Eva.eval(["+", 5, 1], %{})
      6
  """
  @spec eval(expression(), Environment.repository()) :: expression()
  def eval(exp, env) do
    cond do
      is_eva_boolean(exp) ->
        to_elixir_bool(exp)

      is_number(exp) ->
        exp

      is_string(exp) ->
        String.slice(exp, 1..-2)

      is_list(exp) ->
        case exp do
          ["+" | tail] ->
            eval(hd(tail), env) + eval(Enum.at(tail, -1), env)

          ["*" | tail] ->
            eval(hd(tail), env) * eval(Enum.at(tail, -1), env)

          ["-" | tail] ->
            eval(hd(tail), env) - eval(Enum.at(tail, -1), env)

          ["/" | tail] ->
            eval(hd(tail), env) / eval(Enum.at(tail, -1), env)

          ["var" | tail] ->
            Environment.define(env, hd(tail), eval(Enum.at(tail, -1), env))

          [term] ->
            evaluate_term(term, env)

          _ ->
            raise "Unimplemented: #{inspect(exp)}"
        end

      true ->
        raise "Unimplemented: #{inspect(exp)}"
    end
  end

  defp is_eva_boolean(exp) do
    exp == "true" || exp == "false"
  end

  defp to_elixir_bool(exp) do
    case exp do
      "true" -> true
      "false" -> false
      _ -> raise "Error: tried to cast #{inspect(exp)} as a boolean.}"
    end
  end

  defp is_string(exp) do
    is_binary(exp) &&
      String.starts_with?(exp, "\"") &&
      String.ends_with?(exp, "\"")
  end

  defp evaluate_term(term, env) do
    cond do
      is_variable_name(term) ->
        Environment.lookup(env, term)

      true ->
        raise "Unimplemented: #{inspect(term)}"
    end
  end

  defp is_variable_name(exp) do
    is_binary(exp) && String.match?(exp, ~r/^[a-zA-Z][a-zA-Z0-9_]*$/)
  end
end
