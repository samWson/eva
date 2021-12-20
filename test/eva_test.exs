defmodule EvaTest do
  use ExUnit.Case
  doctest Eva

  setup do
    pid = Environment.global()
    %{pid: pid}
  end

  describe "Self evaluating expressions" do
    test "1" , context do
      assert Eva.eval(1, context[:pid]) == 1
    end

    test "\"hello\"", context do
      assert Eva.eval("\"hello\"", context[:pid]) == "hello"
    end
  end

  describe "Math operations" do
    test "[\"+\", 1, 5]", context do
      assert Eva.eval(["+", 1, 5], context[:pid]) == 6
    end

    test "[\"+\", [\"+\", 3, 2], 5]", context do
      assert Eva.eval(["+", ["+", 3, 2], 5], context[:pid]) == 10
    end

    test "[\"+\", [\"*\", 3, 2], 5]", context do
      assert Eva.eval(["+", ["*", 3, 2], 5], context[:pid]) == 11
    end

    test "[\"+\", [\"/\", 4, 2], 5]", context do
      assert Eva.eval(["+", ["/", 4, 2], 5], context[:pid]) == 7
    end

    test "[\"+\", [\"-\", 3, 2], 5]", context do
      assert Eva.eval(["+", ["-", 3, 2], 5], context[:pid]) == 6
    end
  end

  describe "Variables" do
    test "[\"var\", \"x\", 10]", context do
      assignment = Eva.eval(["var", "x", 10], context[:pid])

      assert assignment == 10
      assert Eva.eval(["x"], context[:pid]) == 10
    end

    test "[\"var\", \"y\", 100]", context do
      assignment = Eva.eval(["var", "y", 100], context[:pid])

      assert assignment == 100
      assert Eva.eval(["y"], context[:pid]) == 100
    end

    test "adding to the global environment", context do
      assignment = Eva.eval(["var", "z", 1000], context[:pid])

      assert assignment == 1000
      assert Eva.eval(["z"], context[:pid]) == 1000
      assert Eva.eval(["null"], context[:pid]) == nil
      assert Eva.eval(["true"], context[:pid]) == true
      assert Eva.eval(["false"], context[:pid]) == false
      assert Eva.eval(["VERSION"], context[:pid]) == "0.1"
    end

    test "assignment of global to variable and lookup", context do
      assignment = Eva.eval(["var", "isUser", "true"], context[:pid])

      assert assignment == true
      assert Eva.eval(["isUser"], context[:pid]) == true
    end

    test "assignment of expression to variable and lookup", context do
      assignment = Eva.eval(["var", "z", ["*", 2, 2]], context[:pid])

      assert assignment == 4
      assert Eva.eval(["z"], context[:pid]) == 4
    end
  end
end
