defmodule Condition do
  defstruct [:path, :operator, :value]
end

defmodule ConditionSet do
  defstruct [:all, :any]
end

defmodule Rule do
  defstruct [:id, :conditions]

  def new(%{"id"=>id, "conditions"=>conditions}) when is_map(conditions) do
    %Rule{id: id, conditions: to_condition_or_set(conditions)}
  end

  defp to_condition_or_set(map_or_list) do
    case map_or_list do
      %{"path" => _path, "operator" => _operator, "value" => _value} ->
        struct(Condition, map_or_list)

      %{"all" => list} when is_list(list) ->
        %ConditionSet{all: Enum.map(list, &to_condition_or_set(&1))}

      %{"any" => list} when is_list(list) ->
        %ConditionSet{any: Enum.map(list, &to_condition_or_set(&1))}

      _ ->
        raise ArgumentError, "invalid condition or set"
    end
  end
end

"""
example1 = %Rule{
  id: "1",
  conditions: %Condition{
    path: "/operator_test",
    operator: "equals",
    value: "abc"
  }
}

example2 = %Rule{
  id: "2",
  conditions: %ConditionSet{
    all: [
      %Condition{
        path: "/operator_test",
        operator: "equals",
        value: "one"
      },
      %Condition{
        path: "/path/0/test",
        operator: "equals",
        value: "two"
      }
    ]
  }
}

example3 = %Rule{
  id: "3",
  conditions: %ConditionSet{
    any: [
      %Condition{
        path: "/path/0/test",
        operator: "equals",
        value: "one"
      },
      %Condition{
        path: "/path/1/test",
        operator: "equals",
        value: "one"
      }
    ]
  }
}

example4 = %Rule{
  id: "4",
  conditions: %ConditionSet{
    any: [
      %Condition{
        path: "/path/0/test",
        operator: "equals",
        value: "one"
      },
      %ConditionSet{
        all: [
          %Condition{
            path: "/path/0/test",
            operator: "equals",
            value: "one"
          },
          %Condition{
            path: "/path/1/test",
            operator: "equals",
            value: "two"
          }
        ]
      }
    ]
  }
}
"""
