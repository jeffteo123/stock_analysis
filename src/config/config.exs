import Config

config :logger, level: :info

# Configure brod client options here. For Confluent Cloud, you'll typically use SASL/SSL.
# Replace HOST, PORT, API_KEY, API_SECRET below or override via runtime config / environment vars.

config :elixir_kafka_confluent, :kafka,
  endpoints: [
    {System.get_env("KAFKA_HOST") || "localhost", String.to_integer(System.get_env("KAFKA_PORT") || "9092")}
  ],
  client_id: :brod_client,
  # Example opts: enable_ssl and SASL PLAIN for Confluent Cloud
  client_config: %{
    ssl: (System.get_env("KAFKA_SSL") == "true"),
    # brod expects sasl config to be a map like: %{ mechanism: :plain, username: "xxx", password: "yyy" }
    sasl: if(System.get_env("KAFKA_SASL_USERNAME"), do: %{mechanism: :plain, username: System.get_env("KAFKA_SASL_USERNAME"), password: System.get_env("KAFKA_SASL_PASSWORD")}, else: nil),
    # additional options
    reconnect_cool_down_seconds: 5
  }
