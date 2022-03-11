library("stringr")
library("ggplot2")
library("dplyr")
library("writexl")

### GCP ###

gcp_cluster <- read.table("../gke/timings.txt", header = F, sep = " ", colClasses = "numeric")
colnames(gcp_cluster) <- "time_elapsed"
ggplot(gcp_cluster, aes(x=time_elapsed)) +
  geom_histogram(bins=7)
write_xlsx(gcp_cluster,"gcp_cluster.xlsx")

gcp_workload <- read.table("../gke/kubernetes/workload/timings.txt", header = F, sep = " ", colClasses = "numeric")
colnames(gcp_workload) <- "time_elapsed"
ggplot(gcp_workload, aes(x=time_elapsed)) +
  geom_histogram(bins = 20)
write_xlsx(gcp_workload,"gcp_workload.xlsx")

### AWS ###

aws_cluster <- read.table("../eks/timings.txt", header = F, sep = " ", colClasses = "numeric")
colnames(aws_cluster) <- c("time_elapsed", "time_elapsed_oidc")
ggplot(aws_cluster, aes(x=time_elapsed)) +
  geom_histogram(bins=10)
ggplot(aws_cluster, aes(x=time_elapsed_oidc)) +
  geom_histogram(bins=10)
write_xlsx(aws_cluster,"aws_cluster.xlsx")

aws_workload <- read.table("../eks/kubernetes/workload/timings.txt", header = F, sep = " ", colClasses = "numeric")
colnames(aws_workload) <- "time_elapsed"
ggplot(aws_workload, aes(x=time_elapsed)) +
  geom_histogram(bins = 20, color="darkblue", fill="lightblue") +
  #geom_vline(aes(xintercept=mean(time_elapsed), color="blue", linetype="dashed")) +
  geom_density(alpha=.92, fill="#FF6666")
write_xlsx(aws_workload,"aws_workload.xlsx")

### COMBINED ###

# Cluster
aws_cluster$group <- "aws"
aws_cluster_main <- aws_cluster %>% select(-time_elapsed_oidc)
gcp_cluster$group <- "gcp"
cluster_combined <- rbind(aws_cluster_main, gcp_cluster)
cluster <- ggplot(cluster_combined, aes(x=time_elapsed, fill=group)) +
  geom_density() +
  ggtitle("Time elapsed for DR in scenario 2 (with OIDC provider)") + labs(fill = "Vendor", x="Time elapsed (s)", y="Density")
ggsave("cluster.png", plot=cluster)

# Cluster without OIDC
aws_cluster$no_oidc <- aws_cluster$time_elapsed - aws_cluster$time_elapsed_oidc
aws_cluster_no_oidc <- aws_cluster %>% select(c(-time_elapsed, -time_elapsed_oidc))
colnames(aws_cluster_no_oidc) <- c("group", "time_elapsed")
cluster_combined2 <- rbind(aws_cluster_no_oidc, gcp_cluster)
# mean_aws <- mean(aws_cluster_no_oidc$time_elapsed)
# median_aws <- median(aws_cluster_no_oidc$time_elapsed)
# mean_gcp <- mean(gcp_cluster$time_elapsed)
# median_gcp <- median(gcp_cluster$time_elapsed)
# mean_time_difference <- mean_gcp - mean_aws
cluster_no_oidc <- ggplot(cluster_combined2, aes(x=time_elapsed, fill=group)) +
  geom_density(alpha=.5) +
  # geom_vline(aes(xintercept = median_aws), col='red', size=1) +
  # geom_vline(aes(xintercept = median_gcp), col='blue', size=1) +
  ggtitle("Time elapsed for DR in scenario 2 (without OIDC provider)") + labs(fill = "Vendor", x="Time elapsed (s)", y="Density")
ggsave("cluster_no_oidc.png", plot=cluster_no_oidc)

# Workload
aws_workload$group <- "aws"
gcp_workload$group <- "gcp"
workload_combine <- rbind(aws_workload, gcp_workload)
# mean_aws <- mean(aws_workload$time_elapsed)
# median_aws <- median(aws_workload$time_elapsed)
# mean_gcp <- mean(gcp_workload$time_elapsed)
# median_gcp <- median(gcp_workload$time_elapsed)
# mean_time_difference <- mean_gcp - mean_aws
workload <- ggplot(workload_combined, aes(x=time_elapsed, fill=group)) +
  geom_density(alpha=.5) +
  # geom_vline(aes(xintercept = median_aws), col='red', size=1) +
  # geom_vline(aes(xintercept = median_gcp), col='blue', size=1) +
  ggtitle("Time elapsed for recovery in scenario 1") + labs(fill = "Vendor", x="Time elapsed (s)", y="Density")
ggsave("workload.png", plot=workload)
