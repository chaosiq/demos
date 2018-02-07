# Sample Spring Boot Service that consumes another service through Feign and direct to a Url

## To Build into Docker using Maven

First make sure you're running in an environment that has docker available to you. Then execute:

$ ./mvnw package docker:build

Once completed you will have an chaostoolkit/simple-boot-feign-direct-microservice-consumer image available, as seen by executing:

$ docker images

```
REPOSITORY                                                      TAG                 IMAGE ID            CREATED             SIZE
chaostoolkit/simple-boot-feign-direct-microservice-consumer                      latest              39fc873649d9        3 seconds ago       667.6 MB
```





