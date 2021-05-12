pkgs <- c("foreach", "redux", "doRedis", "RedisParam", "BiocManager", "remotes")
install.packages(pkgs)
if (!requireNamespace("doRedis", quietly = TRUE)){
    BiocManager::install("bwlewis/doRedis", update=FALSE, upgrade = "never")
}

if (!requireNamespace("RedisParam", quietly = TRUE)){
    BiocManager::install("mtmorgan/RedisParam", update=FALSE, upgrade = "never")
}