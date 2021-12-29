defmodule EnvironmentTest do
  use ExUnit.Case
  doctest Environment

  describe "environment variables" do
    test "it adds new variables to a given environment and returns the variable" do
      pid = Environment.start_link()

      value = Environment.define(pid, "bashrc", "~/.bashrc")

      assert value == "~/.bashrc"
      assert Environment.lookup(pid, "bashrc") == "~/.bashrc"
    end
  end

  describe "undefined variables lookup" do
    test "it returns `:undefined`" do
      pid = Environment.start_link()

      assert Environment.lookup(pid, "x") == :undefined
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

  describe "inherited environments" do
    test ~s(when "x" is not defined in the child it will lookup "x" in the parent) do
      parent = Environment.start_link()
      Environment.define(parent, "x", 10)

      child = Environment.start_link(parent)

      assert Environment.lookup(child, "x") == 10
    end

    test ~s(when "x" is defined in the child and the parent the child variable will shadow the parent) do
      parent = Environment.start_link()
      Environment.define(parent, "x", 10)

      child = Environment.start_link(parent)
      Environment.define(child, "x", 20)

      assert Environment.lookup(child, "x") == 20
    end

    test ~s(when "x" is not defined in the child or parent the lookup returns `:undefined`) do
      parent = Environment.start_link()
      child = Environment.start_link(parent)

      assert Environment.lookup(child, "x") == :undefined
    end
  end

  describe "assignment to an existing variable" do
    test "it resolves the variable, assigns the new value, and returns it" do
      env = Environment.start_link()
      Environment.define(env, "x", 10)

      assert Environment.lookup(env, "x") == 10

      assert Environment.assign(env, "x", 100) == 100
      assert Environment.lookup(env, "x") == 100
    end
  end

  describe "assignment to a non-existant variable" do
    test "it returns `:undefined`" do
      env = Environment.start_link()
      assert Environment.assign(env, "x", 100) == :undefined
    end
  end
end
