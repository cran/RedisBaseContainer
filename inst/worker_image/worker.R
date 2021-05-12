## Initialize the variables
workerId <- Sys.getenv("workerId")
queue <- NULL
host <- "localhost"
port <- 6379
password <- NULL
timeout <- 60
backend <- "doRedis"

## create a file indicating the worker is running
file.create(paste0("runningWorkers/", workerId))
## remove the file when exiting R session
final.env <- new.env()
final.env$workerId <- workerId
final.func <- function(e) {
  file.remove(paste0("runningWorkers/", e$workerId))
}
reg.finalizer(final.env, final.func, onexit = TRUE)

## Get the arguments from the environment variables
if (Sys.getenv("queueName") != "") {
  queue <- Sys.getenv("queueName")
} else {
  stop("The queue does not exist!")
}
if (Sys.getenv("serverIp") != "") {
  host <- Sys.getenv("serverIp")
}
if (Sys.getenv("serverPort") != "") {
  port <- as.numeric(Sys.getenv("serverPort"))
}
if (Sys.getenv("serverPassword") != "") {
  password <- Sys.getenv("serverPassword")
}
if (Sys.getenv("serverTimeout") != "") {
  timeout <- as.numeric(Sys.getenv("serverTimeout"))
}
if (Sys.getenv("backend") != "") {
  backend <- Sys.getenv("backend")
}

## Debug info
if (workerId == 1) {
  message("Queue: ", queue)
  message("Server: ", host)
  message("Port: ", port)
  message("password: ", ifelse(!is.null(password), "set", "not set"))
  message("Timeout: ", timeout)
  message("Backend: ", backend)
}

runPerContainer <- function(expr) {
  if (workerId == 1) {
    expr
  }
}

## Try to connect to the redis server
time1 <- Sys.time()
success <- FALSE
error <- NULL
while (as.numeric(Sys.time() - time1, "secs") < timeout && !success) {
  tryCatch({
    if (backend == "doRedis") {
      suppressMessages(library(doRedis))
      redisWorker(queue, host = host, port = port, password = password)
      success <<- TRUE
    }
    if (backend == "RedisParam") {
      suppressMessages(library(RedisParam))
      p <- RedisParam(jobname = queue, manager.hostname = host, manager.port = port, manager.password = password, is.worker = TRUE)
      bpstart(p)
      success <<- TRUE
    }
  },
        error = function(e) {
          error <<- e
        }
    )
}

## quit message
if (success) {
  message(paste0("Worker ", workerId, " exits successfully"))
  file.create(paste0("doneWorkers/", workerId))
} else {
  message(paste0("Worker ", workerId, " reports error:\n", error$message))
}


