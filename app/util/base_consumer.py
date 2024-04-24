import pika
import time


class RabbitMqConsumer():

    def __init__(self):
        try:
            print("Connecting to localhost in container")
            connection = pika.BlockingConnection(pika.ConnectionParameters("rabbitmq", heartbeat=30, connection_attempts=10))
        except Exception as e:
            print("Connecting to main host machine")
            connection = pika.BlockingConnection(pika.ConnectionParameters('docker.for.mac.localhost', heartbeat=30, connection_attempts=10))
        self.channel = connection.channel()

    def callback(self, ch, method, properties, body):
        print(f"Received message: {body}")

    def consume_queue(self, exchange, routing_key, queue_name, callback):
        exchange_name = exchange
        self.channel.exchange_declare(exchange=exchange_name, exchange_type='topic')
        self.channel.queue_declare(queue=queue_name)
        self.channel.queue_bind(exchange=exchange_name, queue=queue_name, routing_key=routing_key)
        self.channel.basic_consume(queue=queue_name, on_message_callback=callback, auto_ack=True)
        print(f"Listening to queue {queue_name}.")
        self.channel.start_consuming()
