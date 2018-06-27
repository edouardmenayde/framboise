defmodule Framboise.MixProject do
  use Mix.Project

  def project do
    [
      app: :framboise,
      version: "0.1.0",
      elixir: "~> 1.6",
      deps: deps(),
      name: "Framboise"
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
      {:ecto, ">= 2.1.0"},
      {:explode, ">= 1.0.0"},
      {:phoenix, ">= 1.3.0"},
      {:ex_doc, "~> 0.13.0", only: [:docs, :dev]}
    ]
  end
end
