defmodule Cleaner.MixProject do
  use Mix.Project

  def project do
    [
      app: :cleaner,
      version: "0.1.0",
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Cleaner.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_gram, "~> 0.52"},
      {:tesla, "~> 1.2"},
      {:hackney, "~> 1.12"},
      {:jason, ">= 1.0.0"},
      {:oban, "~> 2.17"},
      {:postgrex, ">= 0.0.0"},
      {:secret_vault, "~> 1.0"},
      {:credo, "~> 1.7.3", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.4.3", only: [:dev, :test], runtime: false},
      {:mix_audit, "~> 2.1.2", only: [:dev, :test], runtime: false},
      {:styler, "~> 0.11.9", only: [:dev, :test], runtime: false}
    ]
  end

  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate"],
      ci: [
        "compile --all-warnings --warnings-as-errors",
        "format --check-formatted",
        "credo --strict",
        "deps.audit",
        "dialyzer"
      ]
    ]
  end
end