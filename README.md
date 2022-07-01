# Velero Cloud Tests in GCP and AWS

Disaster Recovery Analysis of different Cloud Managed Kubernetes Clusters

Disaster Recovery is nowadays an increasingly important topic of research, as society is depending more and more on technology and communications for every task or process, be it related to business or government. This applies to systems, data, and its links. In recent years, there has been a shift in production systems towards the usage of Kubernetes, which is a piece of software that orchestrates computing resources in a different paradigm. This tool improves, but not solves completely, several aspects of a disaster recovery process, as it has built-in replication and scaling of the applications running within. It also allows easy deployment of load balancers and because of its design, it facilitates the migration process of workloads. However, the literature suggests that disaster recovery addressing specifically Kubernetes is not well studied, while progressively more companies are making heavy use of it. In this dissertation, Disaster Recovery procedures are investigated, leveraging Kubernetes in the cloud. Mainly, the Recovery Time Objective (RTO) and partially, the Recovery Point Objective (RPO) are studied in the context of two cloud providers in this dissertation. These providers include Amazon Web Services and Google Cloud Platform. Two main disasters that a cloud user could suffer are characterised: The first, a software update issue; and the second, a cloud zonal outage. For the given scenarios, it has been found that AWS has a mean noticeable shorter RTO in the first scenario compared to GCP. However, in the second scenario, the RTO was surprisingly longer than GCP, mainly because an OpenID Cloud Identity Provider was set in place in AWS. 

Final project presented as a Dissertation in Edinburgh Napier University as a part of my MSc in Data Engineering. 

## Author

* **Sergio Fernández** - *Creator* - [DrumSergio](https://github.com/DrumSergio)

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details

