defmodule ElixirKafkaConfluent.MixProject do
  use Mix.Project

  def project do
    [
      app: :elixir_kafka_confluent,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {ElixirKafkaConfluent.Application, []}
    ]
  end

  defp deps do
    [
      # brod is a battle-tested Erlang Kafka client; it works well with Confluent Kafka
      {:brod, "~> 3.16"}
    ]
  end
end
