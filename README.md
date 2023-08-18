# JudgeJson
An Elixir rule engine where rules are json objects. The judge gives verdicts on data and returns any matched rules.


## Installation

[Available in Hex](https://hex.pm/packages/judge_json), the package can be installed
by adding `judge_json` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:judge_json, ">= 0.1.0"}
  ]
end
```

## Quick Start Example
payload
```json
{
    "data": {
        "person": {
            "name": "Lionel",
            "last_name": "Messi",
            "likes": [
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
                        "operator": "equal",
                        "value": "Lionel"
                    },
                    {
                        "path": "/person/last_name",
                        "operator": "equal",
                        "value": "Messi"
                    },
                    {
                        "path": "/person/likes",
                        "operator": "contains",
                        "value": "soccer"
                    }
                ]
            },
            "action": "collect_signature.exs"
        }
    ]
}
```
```elixir
iex> JudgeJson.evaluate(payload)
```
Returns a list of matched rules

## Documention and Usage
Docs can be found at <https://hexdocs.pm/judge_json>

Rule = Condition + Action

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
- equal
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
            "operator": "equal",
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
