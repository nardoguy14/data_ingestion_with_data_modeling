import pika

from domain.rabbit_mq_routing_keys import RabbitmqRoutingKeys


class RabbitMqPublisher():
    exchange = "waymark_exchange"

    def send_new_patient_memberships(self, message):
        self.send_message_to_queue(routing_key=RabbitmqRoutingKeys.CREATE_PATIENT_MEMBERSHIP.name,
                                   message=message)

    def send_new_patient_claims(self, message):
        self.send_message_to_queue(routing_key=RabbitmqRoutingKeys.CREATE_PATIENT_CLAIMS.name,
                                   message=message)


    def send_message_to_queue(self, routing_key: str, message: str):
        connection = pika.BlockingConnection(pika.ConnectionParameters('rabbitmq'))
        channel = connection.channel()
        channel.basic_publish(exchange=self.exchange,
                              routing_key=f'cmd.{routing_key}',
                              body=message)
        print(f"Sent message to RabbitMQ: {message}")
        connection.close()
