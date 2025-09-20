from confluent_kafka import Producer, Consumer

class kafka_class:
    def __init__(self, config_file_path):
        self.config = self._read_config(config_file_path)
        
    def _read_config(self, config_file_path):
        config = {}
        try:
            with open(config_file_path) as fh:
                for line in fh:
                    line = line.strip()
                    if len(line) != 0 and line[0] != "#":
                        parameter, value = line.strip().split('=', 1)
                        config[parameter] = value.strip()
        except FileNotFoundError:
            raise Exception("Error: The file was not found.")
        return config
        
    def produce(self, topic, key, value):
        # creates a new producer instance
        producer = Producer(self.config)
        producer.produce(topic, key=key, value=value)
        print(f"Produced message to topic {topic}: key = {key:12} value = {value:12}")

        # send any outstanding or buffered messages to the Kafka broker
        producer.flush()

    def consume(topic, config):
        # sets the consumer group ID and offset
        config["group.id"] = "python-group-1"
        config["auto.offset.reset"] = "earliest"

        # creates a new consumer instance
        consumer = Consumer(config)

        # subscribes to the specified topic
        consumer.subscribe([topic])

        try:
            while True:
                # consumer polls the topic and prints any incoming messages
                msg = consumer.poll(1.0)
                if msg is not None and msg.error() is None:
                    key = msg.key().decode("utf-8")
                    value = msg.value().decode("utf-8")
                    print(f"Consumed message from topic {topic}: key = {key:12} value = {value:12}")
        except KeyboardInterrupt:
            pass
        finally:
            # closes the consumer connection
            consumer.close()
