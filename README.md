# judge_json
An Elixir rule engine where rules are json objects. The judge gives verdicts on data and returns any matched rules.


## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `judge_json` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:judge_json, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/judge_json>.

### About
This project is inspired by:
- https://github.com/santalvarez/python-rule-engine
- https://github.com/CacheControl/json-rules-engine

## Quick Start Example
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
Return is an array of matched rules

## Rule Schema
The rule schema is very flexible and the only strict requirements are on the conditions. You can add your own rule id and action schema. If a rule is matched, the entire object is returned.

Judge Json is storage and action agnostic. Ideally you can store/load rules from a DB and evaluate on incoming json payloads. Handler code can then evaluate rules and action however you like. 

Example:
```json
{
    "id": "",
    "conditions": {},
    "action": {}
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


