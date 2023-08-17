defmodule JudgeJsonTest do
  use ExUnit.Case
  doctest JudgeJson

  test "operator test: string contains" do
    payload = %{
      "data"=> %{
        "operator_test"=> "onetwothree"
      },
      "rules"=> [
        %{
          "id"=> "test_rule",
          "conditions"=> %{
              "all"=> [
                  %{
                      "path"=> "/operator_test",
                      "operator"=> "contains",
                      "value"=> "one"
                  }
              ]
          }
        }
      ]
    }
    results = JudgeJson.evaluate(payload)
    assert results != []
    assert length(results) == 1
  end

  test "operator test: list contains" do
    payload = %{
      "data"=> %{
        "operator_test"=> ["one", "two", "three"]
      },
      "rules"=> [
        %{
          "id"=> "test_rule",
          "conditions"=> %{
              "all"=> [
                  %{
                      "path"=> "/operator_test",
                      "operator"=> "contains",
                      "value"=> "one"
                  }
              ]
          }
        }
      ]
    }
    results = JudgeJson.evaluate(payload)
    assert results != []
    assert length(results) == 1
  end

  test "operator test: map contains" do
    payload = %{
      "data"=> %{
        "operator_test"=> %{"one"=>1, "two"=>2, "three"=>3}
      },
      "rules"=> [
        %{
          "id"=> "test_rule",
          "conditions"=> %{
              "all"=> [
                  %{
                      "path"=> "/operator_test",
                      "operator"=> "contains",
                      "value"=> "one"
                  }
              ]
          }
        }
      ]
    }
    results = JudgeJson.evaluate(payload)
    assert results != []
    assert length(results) == 1
  end

  test "operator test: string equal" do
    payload = %{
      "data"=> %{
        "operator_test"=> "one"
      },
      "rules"=> [
        %{
          "id"=> "test_rule",
          "conditions"=> %{
              "all"=> [
                  %{
                      "path"=> "/operator_test",
                      "operator"=> "contains",
                      "value"=> "one"
                  }
              ]
          }
        }
      ]
    }
    results = JudgeJson.evaluate(payload)
    assert results != []
    assert length(results) == 1
  end

  test "broken JsonPointer.get/2" do
    payload = %{
      "data"=> %{
        "operator_test"=> "one"
      },
      "rules"=> [
        %{
          "id"=> "test_rule",
          "conditions"=> %{
              "all"=> [
                  %{
                      "path"=> "/nil",
                      "operator"=> "contains",
                      "value"=> "one"
                  }
              ]
          }
        }
      ]
    }
    results = JudgeJson.evaluate(payload)
    assert results == []
  end

end
