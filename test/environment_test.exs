defmodule EnvironmentTest do
  use ExUnit.Case
  doctest Environment

  describe "environment variables" do
    test "it adds new variables to a given environment and returns the variable" do
      pid = Environment.start_link()

      value = Environment.define(pid, "bashrc", "~/.bashrc")

      assert value == "~/.bashrc"
      assert Environment.lookup(pid, "bashrc")
    end
  end

  describe "global environment" do
    test "it returns an initialized global environment process" do
      pid = Environment.global()

      assert Environment.lookup(pid, "null") == nil
      assert Environment.lookup(pid, "true") == true
      assert Environment.lookup(pid, "false") == false
      assert Environment.lookup(pid, "VERSION") == "0.1"
    end
  end
end
