library(caret)

## Calculation of Sample size
gcp_cluster <- read.table("../gke/timings.txt", header = F, sep = " ", colClasses = "numeric")
colnames(gcp_cluster) <- "time_elapsed"
gcp_cluster_scaled <- predict(preProcess(gcp_cluster, method = c("range")), gcp_cluster)

gcp_workload <- read.table("../gke/kubernetes/workload/timings.txt", header = F, sep = " ", colClasses = "numeric")
colnames(gcp_workload) <- "time_elapsed"
gcp_workload_scaled <- predict(preProcess(gcp_workload, method = c("range")), gcp_workload)

aws_cluster <- read.table("../eks/timings.txt", header = F, sep = " ", colClasses = "numeric")
colnames(aws_cluster) <- c("time_elapsed", "time_elapsed_no_oidc")
aws_cluster_scaled <- predict(preProcess(aws_cluster, method = c("range")), aws_cluster)

aws_workload <- read.table("../eks/kubernetes/workload/timings.txt", header = F, sep = " ", colClasses = "numeric")
colnames(aws_workload) <- "time_elapsed"
aws_workload_scaled <- predict(preProcess(aws_workload, method = c("range")), aws_workload)

sd_gcp_cluster <- sd(unlist(gcp_cluster_scaled))
sd_gcp_workload <- sd(unlist(gcp_workload_scaled))

sd_aws_cluster <- sd(aws_cluster_scaled$time_elapsed)
sd_aws_cluster_no_oidc <- sd(aws_cluster_scaled$time_elapsed_no_oidc)
sd_aws_workload <- sd(unlist(aws_workload_scaled))

sample_size_95_gcp_cluster <-  (1.96)^2 * sd_gcp_cluster * (1 - sd_gcp_cluster) / (0.05)^2
sample_size_95_gcp_workload <-  (1.96)^2 * sd_gcp_workload* (1 - sd_gcp_workload) / (0.05)^2
sample_size_95_aws_cluster <-  (1.96)^2 * sd_aws_cluster* (1 - sd_aws_cluster) / (0.05)^2
sample_size_95_aws_cluster_no_oidc <-  (1.96)^2 * sd_aws_cluster_no_oidc * (1 - sd_aws_cluster_no_oidc) / (0.05)^2
sample_size_95_aws_workload <-  (1.96)^2 * sd_aws_workload* (1 - sd_aws_workload) / (0.05)^2
