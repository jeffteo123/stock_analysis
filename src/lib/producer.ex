defmodule ElixirKafkaConfluent.Producer do
  @moduledoc """
  A small module that starts a brod client (if not started) and exposes helper functions
  to produce messages synchronously or asynchronously.

  Adjust configuration in config/config.exs or via environment variables for Confluent Cloud.
  """

  require Logger

  @app :elixir_kafka_confluent

  def start_client_if_needed() do
    %{endpoints: endpoints, client_id: client_id, client_config: client_config} = Application.fetch_env!(@app, :kafka)

    case :brod.get_client(client_id) do
      {:ok, _pid} ->
        :ok

      {:error, _} ->
        # Convert endpoints to the shape brod expects (list of {host, port})
        # endpoints already should be that shape from config
        :ok = :brod.start_client(endpoints, client_id, client_config)
        Logger.info("Started brod client #{inspect(client_id)} with endpoints #{inspect(endpoints)}")
    end
  end

  @doc "Produce a single message synchronously to a topic/partition. Use partition 0 for simple setups."
  def produce_sync(topic, partition \ 0, key \ nil, value) do
    %{client_id: client_id} = Application.fetch_env!(@app, :kafka)
    start_client_if_needed()

    # brod.produce_sync(client, topic, partition, key, value)
    case :brod.produce_sync(client_id, topic, partition, key, value) do
      {:ok, _offset} = ok ->
        ok

      {:error, reason} = err ->
        Logger.error("Failed to produce to #{topic}: #{inspect(reason)}")
        err
    end
  end

  @doc "Produce many messages asynchronously. messages is a list of {partition, key, value}"
  def produce_many_async(topic, messages) when is_list(messages) do
    %{client_id: client_id} = Application.fetch_env!(@app, :kafka)
    start_client_if_needed()

    for {partition, key, value} <- messages do
      :ok = :brod.produce(client_id, topic, partition, key, value)
    end

    :ok
  end
end