# Build version specific image
This container image is designed so that the version of Bitbucket that you wish to build is pulled from Atlassian at build time. In order to build a version specific image, you must pass in a `--build-arg` parameter with the associated version you wish to build. Use the example below and substitute the `BITBUCKET_VERSION` with the version of your choice.

```
docker build --build-arg BITBUCKET_VERSION=5.1.2 -t dhaws/bitbucket:5.1.2_JFJ-2987 .
```

# Run the container
## Command line
You can run the container from the command line as follows

    docker run \
    -v {some path on Docker host}:/var/atlassian/application-data/bitbucket:z \
    -p 8080:7990 \
    -p 8081:7999 \
    -it kadimasolutions/bitbucket:5.1.2

## Sandbox
The codebase for this image provides a sandbox directory which leverages docker-compose for quickly standing up a sandbox environment. Simply ensure you are in the "sandbox" directory and execute a docker-compose up command.

    cd sandbox
    docker-compose up -d
    docker-compse logs -f       # tail the logs as the sandbox environment starts up
    
    # When you're done with the sandbox, simply take it down
    docker-compose down          # Use -v if you provided any named volumes you want to remove

Some standard directives are included in the "docker-compose.yml" file which can be modified to fit the needs of your particular sandbox requirements.

### The .env file
For any environment variables specified in the format of `${VARIABLE_NAME}` in the docker-compose.yml file, the `.env` file will be used for variable expansion. A `.env` file may look something like this:

    BITBUCKET_PORT=8080
    BITBUCKET_SSH_PORT=8081
    BITBUCKET_LOCAL_HOME=/mnt/bitbucket_home
    DB_NAME=bitbucketdb
    DB_USER=root
    DB_PASSWORD=welcome1

With the above `.env` file, any instance of `${BITBUCKET_PORT}` in the `docker-compose.yml` file, would be expanded to `8080`.

### Image
The image tag can be adjusted based on the version of Bitbucket you want to run

    image: kadimasolutions/bitbucket:5.1.2

### JVM settings
The JVM environment variables specify how much memory to allocate to Bitbucket itself as well as the bundled Elasticsearch instance

    environment:
          JVM_MIN_MEM: 256m         {default: 512m}
          JVM_MAX_MEM: 512m            {default: 1g}
          ES_JVM_MIN_MEM: 256m        {default: 256m}
          ES_JVM_MAX_MEM: 512m        {default: 1g}

### Elasticsearch
Turn off Elasticsearch...which is on by default

    environment:
            ...
            ELASTICSEARCH_ENABLED: false

### Reverse Proxy (_Bitbucket Server 5.0 +_)
Reverse proxy 

    environment:
        ...
        SERVER_SECURE: true
        SERVER_SCHEME: https
        SERVER_PROXY_PORT: 443
        SERVER_PROXY_NAME: bitbucket.kadima.solutions
    
### Port mapping
Map the ports according to what is defined in the `.env` file.
    
    ports:
     - ${BITBUCKET_PORT}:7990            # 7990 is mapped as the Bitbucket HTTP port in the container
     - ${BITBUCKET_SSH_PORT}:7999        # 7999 is mapped as the Bitbucket SSH port in the container

### Volume mapping
The only required volume for this container is the Bitbucket Home which is where all persisted File System information is kept. The path on the left hand side of the colon can be a path volume or a named volume on the Docker host. 

The path on the right hand side of the colon, is the path inside the container where the Bitbucket Home is expected to be. This path must not be altered if you want your external volume to be used as the container's Bitbucket Home.

    volumes:
     - ${BITBUCKET_LOCAL_HOME}:/var/atlassian/application-data/bitbucket:z
