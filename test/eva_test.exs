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

  describe "Comparison operators" do
    test ~s(["<", 1, 4] is true), context do
      assert Eva.eval(["<", 1, 4], context[:pid])
    end

    test ~s(["<", 4, 4] is false), context do
      refute Eva.eval(["<", 4, 4], context[:pid])
    end

    test ~s([">", 4, 1] is true), context do
      assert Eva.eval([">", 4, 1], context[:pid])
    end

    test ~s([">", 4, 4] is false), context do
      refute Eva.eval([">", 4, 4], context[:pid])
    end

    test ~s(["<=", 4, 4] is true), context do
      assert Eva.eval(["<=", 4, 4], context[:pid])
    end

    test ~s(["<=", 5, 4] is false), context do
      refute Eva.eval(["<=", 5, 4], context[:pid])
    end

    test ~s([">=", 1, 4] is true), context do
      assert Eva.eval([">=", 4, 4], context[:pid])
    end

    test ~s([">=", 1, 4] is false), context do
      refute Eva.eval([">=", 1, 4], context[:pid])
    end

    test ~s(["=", 1, 4] is true), context do
      assert Eva.eval(["=", 4, 4], context[:pid])
    end

    test ~s(["=", 1, 4] is false), context do
      refute Eva.eval(["=", 1, 4], context[:pid])
    end
  end

  describe "Variables" do
    test "[\"var\", \"x\", 10]", context do
      assignment = Eva.eval(["var", "x", 10], context[:pid])

      assert assignment == 10
      assert Eva.eval("x", context[:pid]) == 10
    end

    test "[\"var\", \"y\", 100]", context do
      assignment = Eva.eval(["var", "y", 100], context[:pid])

      assert assignment == 100
      assert Eva.eval("y", context[:pid]) == 100
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

    test "variables not inside a list", context do
      assignment = Eva.eval(["var", "x", 10], context[:pid])

      assert assignment == 10
      assert Eva.eval("x", context[:pid]) == 10
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

    test "assignment to an undeclared variable", context do
      assert_raise RuntimeError, ~s(Assignment to undeclared variable "x".), fn ->
        Eva.eval(["set", "x", 10], context[:pid])
      end
    end
  end

  describe "Blocks" do
    test "two declarations and arithmetic", context do
      block = ["begin",
        ["var", "x", 10],
        ["var", "y", 20],
        ["+", ["*", "x", "y"], 30]
      ]

      assert Eva.eval(block, context[:pid]) == 230
    end

    test "nested block scopes", context do
      block = ["begin",
        ["var", "x", 10],
        ["begin",
          ["var", "x", 20],
          "x"
        ],
        "x"
      ]

      assert Eva.eval(block, context[:pid]) == 10
    end

    test "inner block scope access to outer block scope variables", context do
      block = ["begin",
        ["var", "value", 10],
        ["var", "result", ["begin",
          ["var", "x", ["+", "value", 10]],
            "x"
          ]
        ],
        "result"
      ]

      assert Eva.eval(block, context[:pid]) == 20
    end

    test "variable declaration and assignment", context do
      block = ["begin",
        ["var", "data", 10],
        ["begin",
          ["set", "data", 100]
        ],
        "data"
      ]

      assert Eva.eval(block, context[:pid]) == 100
    end
  end

  describe ~s(`if` expressions) do
    test "alternate branch is executed", context do
      block = ["begin",
        ["var", "x", 10],
        ["var", "y", 0],
        ["if", [">", "x", 10],
          ["set", "y", 20],
          ["set", "y", 30]
        ],
        "y"
      ]

      assert Eva.eval(block, context[:pid]) == 30
    end
  end

  describe "`while` loops" do
    test "loop while condition is `true`", context do
      block = ["begin",
        ["var", "counter", 0],
        ["var", "result", 0],

        ["while", ["<", "counter", 10],
          ["begin",
            ["set", "result", ["+", "result", 1]],
            ["set", "counter", ["+", "counter", 1]]
          ],
        ],
        "result"
      ]

      assert Eva.eval(block, context[:pid]) == 10
    end
  end
end
