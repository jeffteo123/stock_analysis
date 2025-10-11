defmodule ElixirKafkaConfluent.Consumer do
  @moduledoc """
  Example brod group-subscriber callback module.

  If you start this module via :brod.start_link_group_subscriber/5 (as done in the supervisor),
  brod will call the functions below. This implementation handles batches of messages,
  processes them, and commits offsets.

  Be careful: depending on your brod version the callback function names and arities
  might vary slightly. The examples below follow the commonly used brod group subscriber callback shape.
  """

  require Logger

  # Called when subscriber is started for a topic/partition
  def init(_group_id, _topic, _partition) do
    {:ok, %{count: 0}}
  end

  # handle messages: brod will pass a list of messages
  # message shape: %{key: binary | nil, value: binary, offset: integer, partition: integer, topic: binary}
  def handle_message(messages, state) when is_list(messages) do
    Enum.each(messages, fn message ->
      handle_single_message(message)
    end)

    {:ack, %{state | count: state.count + length(messages)}}
  end

  defp handle_single_message(%{key: key, value: value, topic: topic, partition: partition, offset: offset}) do
    Logger.info("Received message topic=#{topic} partition=#{partition} offset=#{offset} key=#{inspect(key)} value=#{inspect(value)}")

    # TODO: decode JSON, call business logic, persist to DB, etc.
    :ok
  end
end
