run_ingestion_service:
	docker-compose down;
	docker-compose build --no-cache; docker-compose up -d

run_ingestion_service_tests:
	make run_ingestion_service;
	echo "Waiting for services to finish starting up";
	sleep 15;
	echo "Loading data into db"
	make load_data;
	echo "Running pytests";
	pytest app/tests/*;
	echo "Running pytests";
	docker-compose down --volume;


run_build_dbt:
	dbt seed --project-dir  waymark --profiles-dir waymark;
	dbt run --project-dir  waymark --profiles-dir waymark;
	dbt test --project-dir  waymark --profiles-dir waymark;

run_docs_dbt:
	dbt docs generate --project-dir waymark --profiles-dir waymark;
	dbt docs serve --project-dir waymark --profiles-dir waymark;

run_docker_dbt:
	docker build -f Dockerfile-dbt -t dbt-waymark .
	docker run -d \
		--name dbt_job_and_docs \
		-e POSTGRES_HOST=${POSTGRES_HOST} -e POSTGRES_DB=${POSTGRES_DB} \
    	-e POSTGRES_USER=${POSTGRES_USER} \
    	-e POSTGRES_PASSWORD=${POSTGRES_PASSWORD} \
		-p 8080:8080 dbt-waymark; \
	docker logs -f dbt_job_and_docs

load_data:
	. .venv/bin/activate; \
	python3 ./test_files/upload_files_script.py; \

setup_env:
	python3 -m venv .venv; \
	. .venv/bin/activate; \
	pip install -r requirements.txt;

run_with_data_load:
	make setup_env; \
	make run_ingestion_service; \
	echo "Sleeping for 15 seconds to let services come up"; \
	sleep 20; \
	echo "Starting API calls for sending files to ingestion service"; \
	make load_data; \
	echo "Starting container service to run dbt and start serving docs"; \
	make run_docker_dbt;

run_without_data_load:
	make setup_env; \
	make run_ingestion_service; \
	echo "Sleeping for 10 seconds to let services come up"; \
	sleep 15; \
	echo "Starting container service to run dbt and start serving docs"; \
	make run_docker_dbt;
