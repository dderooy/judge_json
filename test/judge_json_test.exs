defmodule JudgeJsonTest do
  use ExUnit.Case
  doctest JudgeJson

  test "greets the world" do
    assert JudgeJson.hello() == :world
  end
end
