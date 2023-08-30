# JudgeJson
An Elixir rule engine where rules are json objects. The judge gives verdicts on data and returns any matched rules.

## What and why are rule engines useful?
A rules engine is a flexible piece of software that manages business rules.

Rule = Condition + Action

Think of business rules as dynamically loaded “if-then” statements. A rules engine fits really well with event hooks, event handling, and ETL flows. Generic webhook endpoint → rule match some condition → route / handle payload.

A general design pattern:
- collect / observe incoming data
- evaluate against rules for any matches
- trigger reactionary actions

**The main benefits:**

If you store rules in a DB, you can change your business logic on the fly during runtime. Essentially hot swap your business logic without reloading an app or changing code. It also makes changes much more maintainable with faster turn around time.

Another understated benefit; you can isolate team and company concerns. One team / group can manage business rule CRUD lifecycle while another specialized dev team manages execution logic (action flows and handlers etc). None-coders can create new rules through a form gui and quickly change automations.


## Installation

[Available in Hex](https://hex.pm/packages/judge_json), the package can be installed
by adding `judge_json` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:judge_json, ">= 1.0.0"}
  ]
end
```

## Quick Start Example
```elixir
iex> payload = to_string('
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
iex>
iex> results = JudgeJson.evaluate(payload)
iex>
iex> [
  %{
    "action" => "collect_signature.exs",
    "conditions" => %{
      "all" => [
        %{"operator" => "equals", "path" => "/person/name", "value" => "Lionel"},
        %{
          "operator" => "like",
          "path" => "/person/last_name",
          "value" => "mess"
        },
        %{
          "operator" => "contains",
          "path" => "/person/interests",
          "value" => "soccer"
        }
      ]
    },
    "id" => "123456"
  }
]
```
Notes:
- Returns a list of matched rules with the complete rule json
- JudgeJson.evaluate/1 and JudgeJson.evaluate/2 take elixir native data format or json binary strings
- charlist is used for readability here and converted to binary string via to_string()

## Documention and Usage
Docs can be found at <https://hexdocs.pm/judge_json>

Judge Json is storage and action agnostic. Ideally you can store/load rules from a DB and evaluate on incoming json payloads. Handler code can then evaluate rules and action however you like. 


## Rule Schema
The rule schema is very flexible and the only strict requirements are on the conditions. You can add your own rule id and action schema. If a rule is matched, the entire rule object is appended to the result list.


Example:
```json
{
    "id": "",
    "conditions": {},
    "action": {}
}
```
Example:
```json
{
    "id": "d6f05047-807d-4970-b411-5575fb739dda",
    "conditions": {},
    "action": "on_match_script.exs",
    "meta_data": {}
}
```

## Conditions
Conditions consist of a path, operator, and value.
Example:
```json
{
    "path": "/person/name",
    "operator": "contains",
    "value": "ABC"
}
```

### Path
A [rfc json-pointer](https://www.rfc-editor.org/rfc/rfc6901) for the supplied json payload. 

### Operators
- equals
- not_equal
- greater_than
- less_than
- contains
- not_contains
- like
- regex_match

### Value
The value to match or operate on

## Condition sets
Features:
- all (and) condition sets
- any (or) condition sets
- sets can be nested

Example:
```json
{
    "any": [
        {
            "path": "/source",
            "operator": "contains",
            "value": "X"
        },
        {
            "path": "/product",
            "operator": "contains",
            "value": "Y"
        }
    ]
}
```
Example:
```json
{
    "all": [
        {
            "path": "/name",
            "operator": "equals",
            "value": "A"
        },
        {
            "any": [
                {
                    "path": "/source",
                    "operator": "contains",
                    "value": "X"
                },
                {
                    "path": "/product",
                    "operator": "contains",
                    "value": "Y"
                }
            ]
        }
    ]
}
```

## Credits
This project is inspired by:
- https://github.com/santalvarez/python-rule-engine
- https://github.com/CacheControl/json-rules-engine
