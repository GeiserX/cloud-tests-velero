library("stringr")
library("ggplot2")
library("dplyr")

### GCP ###

gcp_cluster <- read.table("gke/timings.txt", header = F, sep = " ", colClasses = "numeric")
colnames(gcp_cluster) <- "time_elapsed"
ggplot(gcp_cluster, aes(x=time_elapsed)) +
  geom_histogram(bins=6)

gcp_workload <- read.table("gke/kubernetes/workload/timings.txt", header = F, sep = " ", colClasses = "numeric")
colnames(gcp_workload) <- "time_elapsed"
ggplot(gcp_workload, aes(x=time_elapsed)) +
  geom_histogram(bins = 20)

### AWS ###

aws_cluster <- read.table("eks/timings.txt", header = F, sep = " ", colClasses = "numeric")
colnames(aws_cluster) <- c("time_elapsed", "time_elapsed_oidc")
ggplot(aws_cluster, aes(x=V1)) +
  geom_histogram(bins=10)
ggplot(aws_cluster, aes(x=V2)) +
  geom_histogram(bins=10)

aws_workload <- read.table("eks/kubernetes/workload/timings.txt", header = F, sep = " ", colClasses = "numeric")
ggplot(aws_workload, aes(x=V1)) +
  geom_histogram(bins = 20, color="darkblue", fill="lightblue") +
  #geom_vline(aes(xintercept=mean(V1), color="blue", linetype="dashed")) +
  geom_density(alpha=.92, fill="#FF6666")

### COMBINED ###

# Cluster
aws_cluster$group <- "aws"
aws_cluster_main <- aws_cluster %>% select(-V2)
gcp_cluster$group <- "gcp"
cluster_combined <- rbind(aws_cluster_main, gcp_cluster)
ggplot(cluster_combined, aes(x=V1, fill=group)) +
  geom_density() 

# Cluster without OIDC
aws_cluster$no_oidc <- aws_cluster$V1 - aws_cluster$V2
aws_cluster_no_oidc <- aws_cluster %>% select(c(-V1, -V2))
colnames(aws_cluster_no_oidc) <- c("group", "V1")
cluster_combined2 <- rbind(aws_cluster_no_oidc, gcp_cluster)
ggplot(cluster_combined2, aes(x=V1, fill=group)) +
  geom_density(alpha=.5) 

# Workload
aws_workload$group <- "aws"
gcp_workload$group <- "gcp"
workload_combined <- rbind(aws_workload, gcp_workload)
ggplot(workload_combined, aes(x=V1, fill=group)) +
  geom_density(alpha=.5) 
