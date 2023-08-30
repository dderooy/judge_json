defmodule JudgeJsonTest do
  use ExUnit.Case
  doctest JudgeJson

  test "operator test: equals" do
    payload = %{
      "data" => %{
        "operator_test" => "one"
      },
      "rules" => [
        %{
          "id" => "test_rule",
          "conditions" => %{
            "all" => [
              %{
                "path" => "/operator_test",
                "operator" => "equals",
                "value" => "one"
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

  test "operator test: not_equal" do
    payload = %{
      "data" => %{
        "operator_test" => "one"
      },
      "rules" => [
        %{
          "id" => "test_rule",
          "conditions" => %{
            "all" => [
              %{
                "path" => "/operator_test",
                "operator" => "not_equal",
                "value" => "two"
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

  test "operator test: string contains" do
    payload = %{
      "data" => %{
        "operator_test" => "onetwothree"
      },
      "rules" => [
        %{
          "id" => "test_rule",
          "conditions" => %{
            "all" => [
              %{
                "path" => "/operator_test",
                "operator" => "contains",
                "value" => "one"
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
      "data" => %{
        "operator_test" => ["one", "two", "three"]
      },
      "rules" => [
        %{
          "id" => "test_rule",
          "conditions" => %{
            "all" => [
              %{
                "path" => "/operator_test",
                "operator" => "contains",
                "value" => "one"
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
      "data" => %{
        "operator_test" => %{"one" => 1, "two" => 2, "three" => 3}
      },
      "rules" => [
        %{
          "id" => "test_rule",
          "conditions" => %{
            "all" => [
              %{
                "path" => "/operator_test",
                "operator" => "contains",
                "value" => "one"
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

  test "operator test: like" do
    payload = %{
      "data" => %{
        "operator_test" => "one"
      },
      "rules" => [
        %{
          "id" => "test_rule",
          "conditions" => %{
            "all" => [
              %{
                "path" => "/operator_test",
                "operator" => "like",
                "value" => "ONE"
              }
            ]
          }
        }
      ]
    }

    results = JudgeJson.evaluate(payload)
    assert results != []
    assert length(results) == 1

    payload = %{
      "data" => %{
        "operator_test" => %{"wow" => ["cool", "slick"]}
      },
      "rules" => [
        %{
          "id" => "test_rule",
          "conditions" => %{
            "all" => [
              %{
                "path" => "/operator_test",
                "operator" => "like",
                "value" => "cool"
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

  test "operator test: regex" do
    payload = %{
      "data" => %{
        "operator_test" => "some_email@domain.com"
      },
      "rules" => [
        %{
          "id" => "test_rule",
          "conditions" => %{
            "all" => [
              %{
                "path" => "/operator_test",
                "operator" => "regex_match",
                "value" => "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$"
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

  test "broken JsonPointer" do
    payload = %{
      "data" => %{
        "operator_test" => "one"
      },
      "rules" => [
        %{
          "id" => "test_rule",
          "conditions" => %{
            "all" => [
              %{
                "path" => "/nil",
                "operator" => "contains",
                "value" => "one"
              }
            ]
          }
        }
      ]
    }

    results = JudgeJson.evaluate(payload)
    assert results == []
  end

  test "evaluate/2" do
    data = %{"operator_test" => "one"}

    rules = [
      %{
        "id" => "test_rule",
        "conditions" => %{
          "all" => [
            %{
              "path" => "/operator_test",
              "operator" => "contains",
              "value" => "one"
            }
          ]
        }
      }
    ]

    results = JudgeJson.evaluate(data, rules)
    assert results != []
    assert length(results) == 1
  end

  test "eval json strings" do
    data = to_string('{"operator_test": "one"}')
    rules = to_string('[
      {
        "id": "test_rule",
        "conditions": {
          "all": [
            {
              "path": "/operator_test",
              "operator": "contains",
              "value": "one"
            }
          ]
        }
      }
    ]')
    results = JudgeJson.evaluate(data, rules)
    assert results != []
    assert length(results) == 1

    payload = to_string('
      {
          "data": {
              "person": {
                  "name": "Lionel",
                  "last_name": "Messi",
                  "interests": [
                      "soccer",
                      "hot dogs",
                      "sports"
                  ]
              }
          },
          "rules": [
              {
                  "id": "123456",
                  "conditions": {
                      "all": [
                          {
                              "path": "/person/name",
                              "operator": "equals",
                              "value": "Lionel"
                          },
                          {
                              "path": "/person/last_name",
                              "operator": "like",
                              "value": "mess"
                          },
                          {
                              "path": "/person/interests",
                              "operator": "contains",
                              "value": "soccer"
                          }
                      ]
                  },
                  "action": "collect_signature.exs"
              }
          ]
      }')
    results = JudgeJson.evaluate(payload)
    assert results != []
    assert length(results) == 1

    payload = "{
      \"data\": {\"operator_test\": \"one\"},
      \"rules\": [
        {
          \"id\": \"test_rule\",
          \"conditions\": {
            \"all\": [
              {
                \"path\": \"/operator_test\",
                \"operator\": \"contains\",
                \"value\": \"one\"
              }
            ]
          }
        }
      ]
    }"
    results = JudgeJson.evaluate(payload)
    assert results != []
    assert length(results) == 1
  end

  test "schema validation 1" do
    payload = %{
      "data" => %{
        "operator_test" => "one"
      },
      "rules" => [
        %{
          "id" => "test_rule",
          "conditions" => %{
            "all" => [
              %{
                "path" => "/operator_test",
                "operator" => "equals",
                "value" => "one",
                "a;dsf" => "a;lkdsf"
              }
            ]
          }
        }
      ],
      "asdfadsfasdf" => %{
        "asdf" => "asdf"
      }
    }

    results = JudgeJson.evaluate(payload)
    assert results != []
    assert length(results) == 1
  end

  test "condition nesting" do
    payload = %{
      "data" => %{
        "person" => %{"name" => "bob", "age" => 40},
        "cars" => ["Ford", "GM", "Tesla"],
        "sports" => ["soccer", "basketball", "hockey"]
      },
      "rules" => [
        %{
          "id" => "test_rule",
          "conditions" => %{
            "all" => [
              %{
                "path" => "/person/name",
                "operator" => "equals",
                "value" => "bob"
              },
              %{
                "path" => "/person/age",
                "operator" => "equals",
                "value" => 40
              },
              %{
                "any" => [
                  %{
                    "path" => "/cars",
                    "operator" => "like",
                    "value" => "mazda"
                  },
                  %{
                    "all" => [
                      %{
                        "path" => "/sports",
                        "operator" => "contains",
                        "value" => "soccer"
                      },
                      %{
                        "path" => "/sports",
                        "operator" => "contains",
                        "value" => "hockey"
                      }
                    ]
                  }
                ]
              }
            ]
          }
        }
      ]
    }

    results = JudgeJson.evaluate(payload)
    assert results != []
    assert length(results) == 1
    # dbg(results)
  end
end
