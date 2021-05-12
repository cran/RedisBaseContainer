# Introduction
This are the worker images that will be used in DockerParallel to provide the worker to the cluster. There are two images, namely r-base-worker and bioc-worker. The former one is based on the r-base image and the latter is based on the bioconductor image. The worker image accepts the following environment variables on startup:

1. workerNum: The number of R workers in the container
2. sshPubKey: The ssh public key
3. queueName: the queue name used by the worker to retrive jobs from the server
4. serverIp: The IP of the redis server(default: localhost)
5. serverPort: The port used by the redis server to accept the incoming connection(default: 6379)
6. serverPassword: The password of the redis server
7. serverTimeout: The max wait time in seconds until the Redis connection fails(default: 60s)
8. sysPackages: The additional system packages(URL encoded) that will be installed before running the workers, each package is separated by a commas
9. RPackages: The additional R packages(URL encoded) that will be installed before running the workers, each package is separated by a commas
10. backend: The parallel backend used in the container(default: doRedis)

All images supports the R function `runPerContainer` which can be used to run the R code in a container once when all workers execute the function once.

# Build the image
To build the r-base worker image, run
```
docker build -t r-base-worker . -f Dockerfile_rbase_LATEST
```
To build bioconductor worker, run
```
docker build -t bioc-worker . -f Dockerfile_bioc_RELEASE_3_12
```
# Run the container
To run the doRedis backed r-base worker container
```
docker run -it --env queueName=jobs --env serverPassword=123456 --env workerNum=2 --env backend=doRedis r-base-worker
```
To run the RedisParam backed r-base worker container
```
docker run -it --env queueName=jobs --env serverPassword=123456 --env workerNum=2 --env backend=RedisParam r-base-worker
```
To add an R package to the container
```
docker run -it --env queueName=jobs --env serverPassword=123456 --env workerNum=2 --env RPackages=BiocParallel --env backend=doRedis r-base-worker 
```

## Note
If you want to test the server and the worker on the same machine, you have to set the network mode to "host" to allow the communication between the server and worker. For example
```
docker run -it --env queueName=jobs --env serverIp=localhost --env serverPort=6666 --env serverPassword=123456 --env workerNum=2 --env backend=doRedis --network="host" r-base-worker
```