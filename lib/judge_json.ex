defmodule JudgeJson do
  @moduledoc """
  Documentation for `JudgeJson`.
  """
  require JSONPointer

  @doc """
  evaluate/1 function consumes a map with schema:
  ```json
    {
      "data": {},
      "rules": []
    }
  ```

  """
  def evaluate(%{"data" => data, "rules" => rules}) when is_list(rules) do
    Task.async_stream(rules, fn rule ->
      if match_rule?(data, rule) do
        rule
      end
    end)
    |> Enum.map(fn {:ok, result} -> result end)
    |> Enum.filter(& &1)
  end

  @doc """
  evaluate/2  consumes a json data payload + an array of rules

  """
  def evaluate(data, rules) when is_list(rules) do
    Task.async_stream(rules, fn rule ->
      if match_rule?(data, rule) do
        rule
      end
    end)
    |> Enum.map(fn {:ok, result} -> result end)
    |> Enum.filter(& &1)
  end

  defp match_rule?(data, %{"conditions" => conditions}) do
    match_conditions?(data, conditions)
  end

  @doc false
  defp match_rule?(_, _), do: false

  defp match_conditions?(data, conditions) do
    case conditions do
      %{"all" => all} ->
        Enum.all?(all, fn condition ->
          match_conditions?(data, condition)
        end)

      %{"any" => any} ->
        Enum.any?(any, fn condition ->
          match_conditions?(data, condition)
        end)

      _ ->
        match_condition?(data, conditions)
    end
  end

  defp match_condition?(data, %{"path" => pointer, "operator" => operator, "value" => value}) do
    case JSONPointer.get(data, pointer) do
      {:ok, path} ->
        evaluate_path(path, operator, value)

      {:error, _} ->
        false
    end
  end

  defp evaluate_path(path, "contains", value) when is_binary(path) do
    String.contains?(path, value)
  end

  defp evaluate_path(path, "not_contains", value) when is_binary(path) do
    not String.contains?(path, value)
  end

  defp evaluate_path(path, "contains", value) when is_list(path) do
    value in path
  end

  defp evaluate_path(path, "not_contains", value) when is_list(path) do
    value not in path
  end

  defp evaluate_path(path, "contains", value) when is_map(path) do
    Map.has_key?(path, value)
  end

  defp evaluate_path(path, "not_contains", value) when is_map(path) do
    not Map.has_key?(path, value)
  end

  defp evaluate_path(_path, "contains", _value), do: false

  defp evaluate_path(_path, "not_contains", _value), do: false

  defp evaluate_path(path, "like", value) when is_binary(path) do
    String.contains?(String.downcase(path), String.downcase(value))
  end

  defp evaluate_path(_path, "like", _value), do: false

  defp evaluate_path(path, "regex_match", value) when is_binary(path) do
    Regex.match?(value, path)
  end

  defp evaluate_path(_path, "regex_match", _value), do: false

  defp evaluate_path(path, "equal", value), do: path == value

  defp evaluate_path(path, "not_equal", value), do: path != value

  defp evaluate_path(path, "greater_than", value) when is_number(path), do: path > value

  defp evaluate_path(path, "less_than", value) when is_number(path), do: path < value

  defp evaluate_path(_path, _operator, _value), do: false
end
