defmodule Bouncer.Mixfile do
  use Mix.Project

  defp package do
    [
      files: ["lib", "mix.exs", "README.md", "LICENSE"],
      maintainers: ["Ian Walter"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/ianwalter/bouncer"}
    ]
  end

  defp description do
    """
    Token-based authorization and session management for Phoenix (Elixir)
    """
  end

  def project do
    [
      app: :bouncer,
      version: "0.1.5",
      elixir: ">= 1.0.0",
      elixirc_paths: elixirc_paths(Mix.env),
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      deps: deps,
      description: description,
      package: package
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/mocks"]
  defp elixirc_paths(_),     do: ["lib"]

  defp applications(:test), do: [:phoenix, :logger]
  defp applications(_), do: [:logger]

  def application do
    [mod: {Bouncer, []}, applications: applications(Mix.env)]
  end

  defp deps do
    [
      {:plug, ">= 1.0.3"},
      {:phoenix, ">= 1.0.0"},
      {:poison, "~> 1.5"},
      {:redix, ">= 0.0.0"},
      {:poolboy, "~> 1.4"},
      {:earmark, "~> 0.1", only: :dev},
      {:ex_doc, "~> 0.10", only: :dev}
    ]
  end
end
