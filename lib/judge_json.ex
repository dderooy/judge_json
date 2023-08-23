defmodule JudgeJson do
  @moduledoc """
  Documentation for `JudgeJson`.
  """
  require JSONPointer
  require Jason

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
      %{"all" => all} when is_list(all) ->
        Enum.all?(all, fn condition ->
          match_conditions?(data, condition)
        end)

      %{"any" => any} when is_list(any) ->
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
        try do
          evaluate_path(path, operator, value)
        catch
          _ -> false
        end

      {:error, _} ->
        false
    end
  end

  @doc false
  defp match_condition?(_, _), do: false

  defp evaluate_path(path, "equals", value), do: path == value

  defp evaluate_path(path, "not_equal", value), do: path != value

  defp evaluate_path(path, "greater_than", value) when is_number(path), do: path > value

  defp evaluate_path(path, "less_than", value) when is_number(path), do: path < value

  defp evaluate_path(path, "contains", value) when is_binary(path),
    do: String.contains?(path, value)

  defp evaluate_path(path, "contains", value) when is_list(path), do: value in path

  defp evaluate_path(path, "contains", value) when is_map(path), do: Map.has_key?(path, value)

  defp evaluate_path(_path, "contains", _value), do: false

  defp evaluate_path(path, "not_contains", value) when is_binary(path),
    do: not String.contains?(path, value)

  defp evaluate_path(path, "not_contains", value) when is_list(path), do: value not in path

  defp evaluate_path(path, "not_contains", value) when is_map(path),
    do: not Map.has_key?(path, value)

  defp evaluate_path(_path, "not_contains", _value), do: false

  defp evaluate_path(path, "like", value) when is_binary(path) and is_binary(value),
    do: String.contains?(String.downcase(path), String.downcase(value))

  defp evaluate_path(path, "like", value) do
    {:ok, like_path} = Jason.encode(path)
    {:ok, like_value} = Jason.encode(value)
    String.contains?(String.downcase(like_path), String.downcase(like_value))
  end

  defp evaluate_path(path, "regex_match", value) when is_binary(path),
    do: Regex.match?(Regex.compile!(value), path)

  defp evaluate_path(_path, "regex_match", _value), do: false

  defp evaluate_path(_path, _operator, _value), do: false
end
