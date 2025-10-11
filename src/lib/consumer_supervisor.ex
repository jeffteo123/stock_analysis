defmodule ElixirKafkaConfluent.ConsumerSupervisor do
  use Supervisor

  @moduledoc "Supervisor that starts group subscribers for configured topics"

  def start_link(_opts) do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    # Configure topics you want to subscribe to here or via runtime env
    topics = String.split(System.get_env("KAFKA_TOPICS") || "test-topic", ",", trim: true)

    children = Enum.map(topics, fn topic ->
      # Each topic uses brod's group subscriber; the callback module below will receive messages
      %{
        id: {:group_subscriber, topic},
        start: {:brod, :start_link_group_subscriber, [
          client_id(),
          group_id(),
          topic,
          ElixirKafkaConfluent.Consumer,
          []
        ]}
      }
    end)

    Supervisor.init(children, strategy: :one_for_one)
  end

  defp client_id(), do: Application.fetch_env!(@app := :elixir_kafka_confluent, :kafka)[:client_id]
  defp group_id(), do: System.get_env("KAFKA_CONSUMER_GROUP") || "elixir_consumer_group"
end
