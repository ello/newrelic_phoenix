defmodule NewRelicPhoenix.Mixfile do
  use Mix.Project

  def project do
    [app: :newrelic_phoenix,
     version: "0.1.0",
     elixir: "~> 1.4",
     package: package(),
     description: description(),
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  def application do
    [extra_applications: [:logger, :lhttpc],
     mod: {NewRelicPhoenix.Application, []}]
  end

  defp deps do
    [
      {:newrelic, "~> 0.1.0", runtime: false},
    ]
  end

  defp package do
    [
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com/ello/newrelic_phoenix"
      },
    ]
  end

  defp description do
    "Yet another New Relic elixir library targeting Phoenix and Ecto."
  end
end
