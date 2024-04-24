# About

This project is an example of how to materialize different
data models utilizing a scalable ingestion service utilizing
docker-compose, docker containers, fastAPI, RabbitMQ, and a 
Postgres Database for the ingestion part. The materlization 
of the data models is then performed upon ingested csv or excel
files that are not loaded into a Postgres database by means of
using dbt to generate both views and tables. This example further
provides a viewpoint

# Dependencies

You will need
- docker
- make
- docker-compose
- python

installed on your machine to run this project.

This project requires you setup some environment variables for Postgres
prior to running. Here is an example of those credentials:

```shell
export POSTGRES_HOST=postgres
export POSTGRES_DB=postgresdb
export POSTGRES_USER=postgres_user
export POSTGRES_PASSWORD=postgres_password
```
Preferably you should shave this to your `~/.bash_profile` or `~/.zshrc` file. 
# Running

This project uses `make` to do the heavy lifting 
of running the different needed services. To get a 
layout of how things get kicked off:

1. make first runs the ingestion service, docker compose runs 4 different services
   2. postgres database
   3. a rabbitmq consumer
   4. a rabbitmq broker instance
   5. a fastapi server to take in files
6. we then wait for 10 seconds or so for the services to all start up
7. after waiting we run a script that is responsible for passing over
   the files to REST service, it will ingest first set 1 of the files, 
   then set 2
8. once the files have bene loaded into the postgres database its time
   to start data modeling
9. a dbt container instance is created seperate from the docker-compose containers,
   this container will
   * generate all the data models and materializations we expect
   * serve up documentation on an open port for users to visit at http://localhost:8080
10. the example is finished, if you want to run it again you should start from a clean state,
    delete the existing volumes for docker, especially the postgres one 
    if you rather not start from a clean slate you can run `make run_without_data_load` to skip
    the dataload step so that you dont overload the same data onto the database

   

```shell
make run_with_data_load
```

# Testing

Testing is done on the data models themselves by utilizing dbt tests. We test at the time dbt container is ran
by performing `dbt test` as part of the make file. The things we test for are uniqueness of certain fields in
the data models as well as `accepted values` for certain columns. We also validate `data type`'s to be sure they
are of the type we desire. 

You are also able to validate the desired models by loading the dbt docs located at http://localhost:8080 after 
running running the service, loading the data into the database, and running dbt to create the data models.

# Design

## Ingestion Service

Given that I have software engineering background, I wanted to show some of the things I've
learned along my journey. I realize that I could have ingested teh data into the Postgres database
with a simple script that imported pandas and did a quick `to_sql` command on the list of files. That
however is not representative of what I know though. I believe that if a proper ingestion service is
built without using AWS cloud resources, you can still build something that can scale with a bit more work.

This approach aims to do just that. It builds a RESTful API service with the intention of intaking files.
It is responsible for saving the files to a location, in this case the same machine as the api server. Althouh
the test files we were provided are small in nature real data coming from large companies is quite large and not
suitable to be waited upon in a RESTful service for saving the contents to a database. For this reason, instead of
the API service being responsible for saving the data to a database, we leave this job up to workers who will consume
a message of new incoming files.

RabbitMQ is the message service we choose to use here. We setup an exchange, queue, and an associated wildcard routing
key on the running RabbitMQ instance ( running in docker as well). The API service publishes to the exchange. The exchange
takes the routing key and forwards it off to the desired queue. The queue stores the messages.

Now a third docker container which can be scaled if need be by means of using the containers with things like Kubernetes
deployments ( which this example does not get into ) is responsible for pulling from the queue reading the file into a 
Pandas Dataframe then ingesting it as is into a `export` schema in our database. This follows the principal of ELT rather
than ETL where we want to just load the data in for data engineers/analytics engineers/data scientists to work with the
data from its source rather than relying on engineers to build out services that transform then load the data into a desired
format into a given table.

The last running container is just the Postgres database image itself for which we load data into and build data models on
using dbt.


## Data Modeling

To fulfill the requirements of this exercise a `dbt` is used to transform the data once loaded into the database. 

I am new to this library and am no means an expert, however given that I followed this approach:
1. the datasets given follow the same file format of `file_type`, `client`, and `period`,
   given that we should never assume data will be the same between clients  of these two file types
   so we should have data models to deal with each `claims` and `patient_registration` file type for `client`
   each `client`, so we look at these two files per client in the db and start there
2. we first deal with erroneous data values and create a model free of errors like
    * invalid state codes
    * invalid zip codes
    * invalid dates like 11/31/2001
3. we then create another model to normalize data to be the same within its own data set i.e:
   * dates should follow the same format like YYYY-MM-DD
   * datetimes should follow the same format as well
   * normalize all the fields established ones we want, like `first_name` rather than `member_first_name` that was
     present in the ingestion file
4. once we have built models for all clients for both `claims` and `patient_registration` we can build
   a model that aggregates all the data from all of the clients but still keeps track of which client that
   patient belonged to
5. from here we are able to start to build tables like only the latest member entries with
   there associated end of eligibility date, and other things like `member_status` and more.

The overall approach is, 
1. deal with errors
2. normalize
3. aggregate different client models into one
4. materialize features

# Questions

## What about this assignment did you find most challenging?

I think the broadness of where you can start and how much you can impelment
made this challenging. Ingestion is a large part of being able to work with the data.
Although there are easier ways to do it, I wanted to build something that 
could scale or be used as containers for a larger system be it on the cloud on 
things like EKS, Lambda, ECS, etc.

## What about this assignment did you find unclear?

There are some things in the requirements that weren't described to well. For instance,
`b. Validate demographic, contact information` was a bit broad. I cleaned up certain things
like invalid zip codes, invalid states, invalid dates, but I'm not sure what other kidns of
validation was required here. I think this could have been made more explicit as to what they
want cleaned up.

## If given opportunities, what would you have done to improve your solutions?

### Testing
A number of things. More testing to be sure around the ingestion service. I struggled
to find time to implement it the way I wanted to but to test this would require more time for sure.
I would want to setup two forms of test. One set of tests that test logic related to the service layer
of the code to be sure it does the approprate calls to save the file to a given location and also be sure
a message is sent to rabbitmq. A second set of tests that would do a end to end test with `pytest`. First 
we would stand up the services for the ingestion portion. Then we would have pytest pass a file to the api service.
We would then validate the end of the data at the database level to see what tables were populated and if the data
we expect to see is present.

### Deployment to Cloud
I would want to declare IaC using Cloudformation to define all these components of Postgres and an RabbitMQ instance.
Defining them in cloudformation as an RDS instance and Amazon MQ would allow me to easily define the resources in the cloud
to work with. Further we would need the code that actually does the deployment. For CICD we could use Github Actions or
a combination of Github Actions with AWS Code Deploy + AWS Codepipeline. This would be responsible for refreshing any infra
needed when we merge to a defined master/main branch. IaC for the databse and event driven parts is great but we'd also need
to think about how we would be running the api service and rabbitmq consumers. If we expect the time of the apis to be of
short duration to just send a message and save a file to S3, we could utilize Lambda and write cloudformation code to have the
api service there. We would want another option thats longer running for the rabbitmq consumers in case they need more time to
deal with larger files that may take more time than the allowed run time of a AWS lambda execution.

### Refactoring Code
There are instances with the RabbitMQ Publisher and Consumer that are redundant in establishing the connection. I was trying
to get a working example out as quickly as I could but I could always make the code better.

### More Documentation
I was sure to add documentation on the models and what they are trying to materialize. However the apis themselves could
use more documentation on the endpoints themselves that would then be accessible via swagger docs. More documentaiton on 
the services would also be beneficial to define the business logic we want of saving the file and sending a message to rabbitmq.
Better documentation on the data models themselves describing all of the columns more indepth would be great. This was taking
a long time to do and I was losing time getting the big milestones done, so if given more time I would like to revisit this.

### More Error Handling
Right now you could send the claims data to the `/patients/membership` endpoint and nothing would fail until after you do so.
Thats a problem and there should be more error handling around raising Bad Request Exceptions with status codes 400 if a individual
tries to upload the wrong file type to a given endpoint intended for another file type. I would like to implement better error responses
rather than just waiting for the ingestion service to throw a 500 status code error.

## Data Models Constructed from Ingested Files
![lineagegraph.jpg](images%2Flineagegraph.jpg)

## Services Responsible for Generating Datamodels and Providing Ingestion
![Waymark Ingestion and Materializing Tables.png](images%2FWaymark%20Ingestion%20and%20Materializing%20Tables.png)

