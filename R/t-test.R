gcp_cluster <- read.table("../gke/timings.txt", header = F, sep = " ", colClasses = "numeric")
colnames(gcp_cluster) <- "time_elapsed"

gcp_workload <- read.table("../gke/kubernetes/workload/timings.txt", header = F, sep = " ", colClasses = "numeric")
colnames(gcp_workload) <- "time_elapsed"

aws_cluster <- read.table("../eks/timings.txt", header = F, sep = " ", colClasses = "numeric")
colnames(aws_cluster) <- c("time_elapsed", "time_elapsed_oidc")

aws_workload <- read.table("../eks/kubernetes/workload/timings.txt", header = F, sep = " ", colClasses = "numeric")
colnames(aws_workload) <- "time_elapsed"

t.test(gcp_cluster$time_elapsed, aws_cluster$time_elapsed) # p=2.2e-16
t.test(gcp_cluster$time_elapsed, aws_cluster$time_elapsed-aws_cluster$time_elapsed_oidc) # p=0.03
t.test(gcp_workload$time_elapsed, aws_workload$time_elapsed) # 4.908e-14

# The p-value of the tests is less than the significance level alpha = 0.05.
# We can conclude that the GCP average timings is significantly different from AWS

