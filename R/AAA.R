###########################
## container provider
###########################
#' The base redis container
#'
#' The base redis container. It should not be directly used by the user.
#'
#' @exportClass RedisContainer
.RedisContainer <- setRefClass(
    "RedisContainer",
    fields = list(
        sysPackages = "CharOrNULL",
        RPackages = "CharOrNULL",
        backend = "CharOrNULL"
    ),
    contains = "DockerContainer"
)
