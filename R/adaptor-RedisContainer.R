#' Configure the server container environment,
#'
#' Configure the server container environment, the environment variable
#' `serverPort`, `serverPassword` and `sshPubKey` will be set in this method
#'
#' @inheritParams DockerParallel::configServerContainerEnv
#' @return A `RedisContainer` object
#' @export
setMethod("configServerContainerEnv", "RedisContainer",
          function(container, cluster, verbose = FALSE){
              if(length(container$RPackages)!=0){
                  warning("The server containder does not support installing R packages")
              }
              if(length(container$sysPackages)!=0){
                  warning("The server containder does not support installing system packages")
              }
              container <- container$copy()

              serverPort <- .getServerPort(cluster)
              serverPassword <- .getServerPassword(cluster)
              sshPubKey <- getSSHPubKeyValue()

              stopifnot(!is.null(serverPort))
              if(is.null(serverPassword)){
                  stop("The server must be password protected!")
              }
              container$environment <- combineList(
                  container$environment,
                  list(
                      serverPort = serverPort,
                      serverPassword = serverPassword,
                      sshPubKey = sshPubKey
                  )
              )
              container
          })

#' Configure the worker container
#'
#' Configure the worker container
#'
#' @inheritParams DockerParallel::configWorkerContainerEnv
#' @return A `RedisContainer` object
#' @export
setMethod("configWorkerContainerEnv", "RedisContainer",
          function(container, cluster, workerNumber, verbose = FALSE){
              container <- container$copy()

              queueName <- .getJobQueueName(cluster)
              serverPort <- .getServerPort(cluster)
              serverPassword <- .getServerPassword(cluster)
              sshPubKey <- getSSHPubKeyValue()
              RPackages <- packPackages(container$RPackages)
              sysPackages <- paste0(container$sysPackages,collapse = ",")
              if(.getServerWorkerSameLAN(cluster)){
                  serverIp <- .getServerPrivateIp(cluster)
              }else{
                  serverIp <- .getServerPublicIp(cluster)
              }

              if(is.null(serverIp)){
                  stop("Fail to find the server Ip")
              }
              stopifnot(!is.null(serverPort))

              container$environment <- combineList(
                  container$environment,
                  list(
                      queueName = queueName,
                      serverIp = serverIp,
                      serverPort = serverPort,
                      serverPassword = serverPassword,
                      sshPubKey = sshPubKey,
                      workerNum = workerNumber,
                      RPackages = RPackages,
                      sysPackages = sysPackages
                  )
              )
              container
          })



#' Get the Redis server container
#'
#' Get the Redis server container from the worker container
#'
#' @inheritParams DockerParallel::getServerContainer
#' @return A `RedisContainer` server container
#' @export
setMethod("getServerContainer", "RedisContainer",function(workerContainer){
    RedisServerContainer()
})




containerExportedMethods <- c("getSysPackages", "setSysPackages", "addSysPackages",
                              "getRPackages", "setRPackages", "addRPackages")


#' Get the exported object
#'
#' Get the exported object. The objects are 'getSysPackages', 'setSysPackages',
#' 'addSysPackages', 'getRPackages', 'setRPackages' and 'addRPackages'. see details
#'
#' @details
#' The function `XSysPackages` can be used to install the system package for the
#' worker container before running the R worker. The package will be installed by
#' `apt-get install`.
#'
#' The function `XRPackages` will install the R packages for the container. The
#' package is installed via `AnVIL::install`. It will first try the fast binary installation,
#' then fallback to `BiocManager::install`. Therefore, you can also provide the GitHub package
#' to this function.
#'
#' Note that these function must be called before deploying the container.
#' Setting the packages will have no effect on the running container.
#'
#'
#' @inheritParams DockerParallel::getExportedObject
#' @inheritParams DockerParallel::getExportedNames
#' @return For the exported function: The current package vector
#' @rdname BiocBPRPPackages
#' @export
setMethod("getExportedNames", "RedisContainer",
          function(x){
              if(x$name == "redisRWorkerContainer")
                  containerExportedMethods
              else
                  character()
          }
)

#' @rdname BiocBPRPPackages
#' @export
setMethod("getExportedObject", "RedisContainer",
          function(x, name){
              if(x$name != "redisRWorkerContainer"){
                  return(NULL)
              }
              if(!name%in%containerExportedMethods)
                  return(NULL)
              get(name)
          }
)





