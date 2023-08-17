defmodule JudgeJson.MixProject do
  use Mix.Project

  def project do
    [
      app: :judge_json,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      name: "judge_json",
      description: "An Elixir rule engine where rules are json objects. The judge gives verdicts on any rule matches for a provided json payload.",
      source_url: "https://github.com/dderooy/judge_json",
      package: package()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
      {:jason, "~> 1.4"},
      {:odgn_json_pointer, "~> 3.0"}
    ]
  end

  def package do
    [
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com/dderooy/judge_json",
      }
    ]
  end
end
