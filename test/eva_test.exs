defmodule EvaTest do
  use ExUnit.Case
  doctest Eva

  describe "Self evaluating expressions" do
    test "1" do
      assert Eva.eval(1) == 1
    end

    test "\"hello\"" do
      assert Eva.eval("\"hello\"") == "hello"
    end
  end

  describe "Math operations" do
    test "[\"+\", 1, 5]" do
      assert Eva.eval(["+", 1, 5]) == 6
    end

    test "[\"+\", [\"+\", 3, 2], 5]" do
      assert Eva.eval(["+", ["+", 3, 2], 5]) == 10
    end
  end
end
