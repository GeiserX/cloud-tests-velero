<p align="center"><img src="docs/images/banner.svg" alt="Velero Cloud Tests banner" width="900"/></p>

<h1 align="center">Velero Cloud Tests</h1>

<p align="center">
  <a href="LICENSE"><img src="https://img.shields.io/github/license/GeiserX/cloud-tests-velero" alt="License"/></a>
</p>

<p align="center"><strong>Disaster Recovery analysis for managed Kubernetes clusters</strong></p>

---

Velero Cloud Tests holds the Terraform, Velero and workload manifests and the timing scripts used to measure disaster recovery times (the RTO, and partly the RPO) on managed Kubernetes in AWS and GCP for two scenarios, a broken software update and a zonal outage, plus the R analysis and the dissertation itself. After a broken update AWS recovered faster than GCP; after a zonal outage GCP was faster, mainly because of the OpenID identity provider set up on AWS. It was the final project of an MSc in Data Engineering at Edinburgh Napier University.

## Quick start

The scripts are the record of the dissertation's runs, with its region, cluster, bucket and backup names written in, so adapt those first. On AWS, from `eks/` (`gke/` holds the same for GCP):

```bash
./test.sh                                 # create the EKS cluster, install Velero, restore the WordPress workload from a backup
cd kubernetes/workload && ./oneliner.sh   # broken-update scenario: delete and restore the workload, 30 timed runs
cd ../.. && ./oneliner.sh                 # zonal-outage scenario: destroy and rebuild the cluster, 4 timed runs
```

Needs `terraform`, the `aws` CLI, `helm` with the `helm-diff` plugin, `helmfile`, `kubectl`, `velero`, and a Velero backup already in the bucket that `terraform/platform-services` creates. The measured times are in the `timings.txt` files, the charts and tests in `R/`, and the write-up in [`Dissertation.pdf`](Dissertation.pdf).

## License

[GPL-3.0-or-later](LICENSE)
