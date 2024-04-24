from services.ingestion_service import IngestionService
from util.base_consumer import RabbitMqConsumer
from domain.rabbit_mq_routing_keys import RabbitmqRoutingKeys


class PatientsRabbitMqConsumer(RabbitMqConsumer):

    def __init__(self):
        super().__init__()
        self.ingestion_service = IngestionService()

    def get_action(self, routing_key):
        print(f'getting action for {routing_key}')
        commands_to_actions = {
            f"cmd.{RabbitmqRoutingKeys.CREATE_PATIENT_MEMBERSHIP.name}": self.handle_patient_registration_message,
            f"cmd.{RabbitmqRoutingKeys.CREATE_PATIENT_CLAIMS.name}": self.handle_patient_claims_message
        }
        return commands_to_actions[routing_key]

    def consume_patient_messages(self):
        self.consume_queue(exchange="waymark_exchange",
                           routing_key=f"cmd.*",
                           queue_name="patient_actions",
                           callback=self.handle_messages)

    def handle_patient_registration_message(self, body):
        client, full_file_path, period = self.common_file_logic(body)
        kind = "patient_registration"
        result = self.ingestion_service.ingest_csv_to_db(full_file_path, kind, client, period)
        print(f"Stored csv file to db with inferred datatypes. Result {result}")

    def common_file_logic(self, body):
        filename = body.decode('utf-8')
        full_file_path = f"/uploaded-files/{filename}"
        file_parts = filename.split("-")
        client = file_parts[2]
        period = file_parts[3].split(".")[0]
        return client, full_file_path, period

    def handle_patient_claims_message(self, body):
        client, full_file_path, period = self.common_file_logic(body)
        kind = "patient_claims"
        result = self.ingestion_service.ingest_csv_to_db(full_file_path, kind, client, period)
        print(f"Stored csv file to db with inferred datatypes. Result {result}")

    def handle_messages(self, ch, method, properties, body):
        print(f"handling message {body}")
        full_routing_key = method.routing_key
        fcn = self.get_action(full_routing_key)
        print("sending body to handler")
        fcn(body)
