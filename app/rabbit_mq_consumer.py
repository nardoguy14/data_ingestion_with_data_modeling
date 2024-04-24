from util.patients_consumer import PatientsRabbitMqConsumer


if __name__ == "__main__":
    patients_consumer = PatientsRabbitMqConsumer()
    patients_consumer.consume_patient_messages()