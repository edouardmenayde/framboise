defmodule Framboise.MixProject do
  use Mix.Project

  def project do
    [
      app: :framboise,
      version: "0.1.0",
      elixir: "~> 1.6",
      description: description(),
      package: package(),
      deps: deps(),
      docs: docs(),
      name: "Framboise",
      source_url: "https://github.com/edouardmenayde/framboise"
    ]
  end

  defp docs do
    [
      main: "Framboise", # The main page in the docs
      extras: ["README.md"]
    ]
  end

  defp description() do
    "Phoenix default rest actions and associated renders for your controller."
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
      {:ex_doc, "~> 0.16", only: [:docs, :dev], runtime: false}
    ]
  end

  defp package() do
    [
      # These are the default files included in the package
      maintainers: ["Edouard Menayde"],
      files: ["lib", "mix.exs", "README*", "LICENSE*"],
      licenses: ["Apache 2.0"],
      links: %{
        "GitHub" => "https://github.com/edouardmenayde/framboise"
      }
    ]
  end
end
