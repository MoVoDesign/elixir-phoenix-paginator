defmodule Pagination.MixProject do
  use Mix.Project

  @source_url "https://github.com/MoVoDesign/elixir-phoenix-paginator.git"
  @doc_url "https://hexdocs.pm/simple_paginator"
  @version "0.2.1"

  def project do
    [
      app: :simple_pagination,
      version: @version,
      elixir: "~> 1.14",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package(),
      docs: docs()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: []
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
      {:phoenix, ">= 1.6.6"},
      {:phoenix_ecto, "> 3.6.0"},
      {:ecto_sql, ">= 3.6.0"},
      {:postgrex, ">= 0.13.0", optional: true},
      {:phoenix_html, ">= 3.0.0"},
      {:phoenix_live_view, ">= 0.17.1"},
      {:ex_doc, ">= 0.29.0", only: :dev},
      {:earmark, ">= 0.2.0", only: :dev},
      {:dialyxir, ">= 0.5.0", only: :dev}
    ]
  end

  defp package() do
    [
      maintainers: ["Lio Aimerie"],
      description: description(),
      licenses: ["MIT"],
      links: %{
        "GitHub" => @source_url,
        "Docs" => @doc_url
      }
    ]
  end

  defp docs(),
    do: [
      # The main page in the docs
      # main: Pagination.Paginator,
      main: "readme",
      assets: ["assets/img"],
      logo: "assets/img/logo.png",
      extras: ["README.md", "CHANGELOG.md"]
    ]

  # defp docs() do
  #   [
  #     main: "readme",
  #     name: "Pagination",
  #     source_ref: "v#{@version}",
  #     canonical: "https://hexdocs.pm/simple-pagination",
  #     # formatters: ["html"],
  #     source_url: @source_url,
  #     extras: ["README.md", "CHANGELOG.md", "LICENSE.md"]
  #   ]
  # end

  defp description() do
    """
    A simple paginator helper for Elixir Phoenix
    """
  end
end
