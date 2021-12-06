defmodule EnvironmentTest do
  use ExUnit.Case
  doctest Environment

  describe "environment variables" do
    test "it adds new variables to a given environment and returns the variable" do
      env = %{"home" => "/user/home"}
      {value, updated_env} = Environment.define(env, "bashrc", "~/.bashrc")

      assert value == "~/.bashrc"
      assert updated_env["home"] == "/user/home"
      assert updated_env["bashrc"] == "~/.bashrc"
    end
  end

  describe "variable lookup" do
    test "returns the value" do
      env = %{"home" => "/user/home"}

      assert Environment.lookup(env, "home") == "/user/home"
    end
  end
end
