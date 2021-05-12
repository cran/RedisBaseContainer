RedisContainer <- function(image = "", name = NULL,  environment = list(),
                           maxWorkerNum = 4L,
                           RPackages = NULL,
                           sysPackages = NULL){
  .RedisContainer$new(
    name=name, image = image,
    environment = environment,
    maxWorkerNum = as.integer(maxWorkerNum),
    RPackages=RPackages,
    sysPackages=sysPackages,
    backend = NULL)
}

#' Common RedisContainer parameter
#'
#' Common RedisContainer parameter
#'
#' @param image Character, the container image
#' @param name Character, the optional name of the container
#' @param environment List, the environment variables in the container
#' @param tag Character, the image tag
#' @rdname RedisContainer-commom-parameters
#' @name RedisContainer-commom-parameters
#' @return No reuturn value
NULL

#' Get the Bioconductor Redis server container
#'
#' Get the Bioconductor Redis server container.
#'
#' @inheritParams RedisContainer-commom-parameters
#' @examples RedisServerContainer()
#' @return a `RedisContainer` object
#' @export
RedisServerContainer <- function(environment = list(), tag = "latest"){
  name <- "redisRServerContainer"
  image <- paste0("dockerparallel/redis-r-server:",tag)
  RedisContainer(image = image, name=name,
                 environment=environment,
                 maxWorkerNum=1L)
}

#' Show the Redis container
#'
#' Show the Redis container
#'
#' @param object The `RedisContainer` object
#' @return No return value
#' @export
setMethod("show", "RedisContainer", function(object){
  cat("Redis container reference object\n")
  cat("  Image:     ", object$image, "\n")
  if(!is.null(object$backend)){
    cat("  backend:   ", object$backend, "\n")
  }
  cat("  maxWorkers:", object$maxWorkerNum, "\n")
  if(!is.null(object$RPackages)){
    cat("  R packages:", paste0(object$RPackages, collapse = ", "), "\n")
  }
  if(!is.null(object$sysPackages)){
    cat("  system packages:", paste0(object$sysPackages, collapse = ", "), "\n")
  }
  cat("  Environment variables:\n")
  for(i in names(object$environment)){
    cat("    ",i,": ", object$environment[[i]], "\n",sep="")
  }
  invisible(NULL)
})
