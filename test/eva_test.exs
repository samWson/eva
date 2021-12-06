defmodule EvaTest do
  use ExUnit.Case
  doctest Eva

  @global Environment.global()

  describe "Self evaluating expressions" do
    test "1" do
      assert Eva.eval(1, %{}) == 1
    end

    test "\"hello\"" do
      assert Eva.eval("\"hello\"", %{}) == "hello"
    end
  end

  describe "Math operations" do
    test "[\"+\", 1, 5]" do
      assert Eva.eval(["+", 1, 5], %{}) == 6
    end

    test "[\"+\", [\"+\", 3, 2], 5]" do
      assert Eva.eval(["+", ["+", 3, 2], 5], %{}) == 10
    end

    test "[\"+\", [\"*\", 3, 2], 5]" do
      assert Eva.eval(["+", ["*", 3, 2], 5], %{}) == 11
    end

    test "[\"+\", [\"/\", 4, 2], 5]" do
      assert Eva.eval(["+", ["/", 4, 2], 5], %{}) == 7
    end

    test "[\"+\", [\"-\", 3, 2], 5]" do
      assert Eva.eval(["+", ["-", 3, 2], 5], %{}) == 6
    end
  end

  describe "Variables" do
    test "[\"var\", \"x\", 10]" do
      {assignment, env} = Eva.eval(["var", "x", 10], %{})

      assert assignment == 10
      assert Eva.eval(["x"], env) == 10
    end

    test "[\"var\", \"y\", 100]" do
      {assignment, env} = Eva.eval(["var", "y", 100], %{})

      assert assignment == 100
      assert Eva.eval(["y"], env) == 100
    end

    test "adding to the global environment" do
      {assignment, env} = Eva.eval(["var", "z", 1000], @global)

      assert assignment == 1000
      assert Eva.eval(["z"], env) == 1000
      assert Eva.eval(["null"], env) == nil
      assert Eva.eval(["true"], env) == true
      assert Eva.eval(["false"], env) == false
      assert Eva.eval(["VERSION"], env) == "0.1"
    end

    test "assignment of global to variable and lookup" do
      {assignment, env} = Eva.eval(["var", "isUser", "true"], @global)

      assert assignment == true
      assert Eva.eval(["isUser"], env) == true
    end

    test "assignment of expression to variable and lookup" do
      {assignment, env} = Eva.eval(["var", "z", ["*", 2, 2]], @global)

      assert assignment == 4
      assert Eva.eval(["z"], env) == 4
    end
  end
end
