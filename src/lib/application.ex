defmodule ElixirKafkaConfluent.Application do
  use Application
  require Logger
  alias ElixirKafkaConfluent.Producer

  def start(_type, _args) do
    children = [
      {ElixirKafkaConfluent.ConsumerSupervisor, []}
    ]

    opts = [strategy: :one_for_one, name: ElixirKafkaConfluent.Supervisor]
    {:ok, pid} = Supervisor.start_link(children, opts)

    # Start Kafka client and send messages after startup
    spawn(fn ->
      Process.sleep(2000) # short delay to ensure consumer connected
      Logger.info("🚀 Producing startup messages to Kafka...")
      Producer.start_client_if_needed()

      for i <- 1..5 do
        msg = "Message ##{i} from ElixirKafkaConfluent"
        Producer.produce_sync("test-topic", 0, "key-#{i}", msg)
        Logger.info("Produced: #{msg}")
      end
    end)

    {:ok, pid}
  end
end
