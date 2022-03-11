resource "google_compute_network" "gke-vpc" {
  name                    = "gke-cluster-test-sergio"
  description             = "GKE Cluster Network"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "gke-vpc-subnet" {
  name                     = "gke-worker-nodes"
  description                = "Subnet for worker nodes from GKE"
  ip_cidr_range            = local.vpc.node_subnet_ip_range
  network                  = google_compute_network.gke-vpc.self_link
  private_ip_google_access = true
  secondary_ip_range {
    range_name    = local.vpc.pod_subnet_name
    ip_cidr_range = local.vpc.pod_subnet_ip_range
  }
  secondary_ip_range {
    range_name    = "gke-services"
    ip_cidr_range = local.vpc.service_subnet_ip_range
  }
}

resource "google_compute_router" "gke-node-nat" {
  name    = "gke-node-nat"
  network = google_compute_network.gke-vpc.self_link
}

resource "google_compute_address" "gke-node-nat" {
  name   = "gke-node-nat-external-address-test-sergio"
}

resource "google_compute_router_nat" "gke-node-nat" {
  name                               = "gke-node-nat"
  router                             = google_compute_router.gke-node-nat.name
  nat_ip_allocate_option             = "MANUAL_ONLY"
  nat_ips                            = [google_compute_address.gke-node-nat.self_link]
  min_ports_per_vm                   = local.node_nat_ports_per_vm
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"
  subnetwork {
    name                    = google_compute_subnetwork.gke-vpc-subnet.self_link
    source_ip_ranges_to_nat = ["PRIMARY_IP_RANGE"]
  }
  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

resource "google_compute_router" "gke-pod-nat" {
  name    = "gke-pod-nat"
  network = google_compute_network.gke-vpc.self_link
}

resource "google_compute_address" "gke-pod-nat" {
  name   = "gke-pod-nat-external-address-test-sergio"
}

resource "google_compute_router_nat" "gke-pod-nat" {
  name                               = "gke-pod-nat"
  router                             = google_compute_router.gke-pod-nat.name
  nat_ip_allocate_option             = "MANUAL_ONLY"
  nat_ips                            = [google_compute_address.gke-pod-nat.self_link]
  min_ports_per_vm                   = local.pod_nat_ports_per_vm
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"
  subnetwork {
    name                     = google_compute_subnetwork.gke-vpc-subnet.self_link
    source_ip_ranges_to_nat  = ["LIST_OF_SECONDARY_IP_RANGES"]
    secondary_ip_range_names = [local.vpc.pod_subnet_name]
  }
  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

resource "google_compute_firewall" "mgmt" {
  name        = "${google_compute_network.gke-vpc.name}-allow-mgmt-access"
  network     = google_compute_network.gke-vpc.name
  description = "Restrict managment access to source prefixes"

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["22", "80", "443"]
  }

  source_ranges = local.fw_mgmt_sources
}

resource "google_container_cluster" "gke-cluster" {
  name               = local.cluster.name
  min_master_version = local.cluster.min_master_version
  location           = var.gcp_default_zone
  initial_node_count       = "1"
  remove_default_node_pool = "true"
  enable_legacy_abac       = "false"
  network                  = google_compute_network.gke-vpc.name
  subnetwork               = google_compute_subnetwork.gke-vpc-subnet.name
  private_cluster_config {
    enable_private_nodes   = true
    master_ipv4_cidr_block = local.cluster.master_ipv4_cidr_block
    enable_private_endpoint = false
  }
  master_authorized_networks_config {
    cidr_blocks {
      cidr_block   = "0.0.0.0/0"
      display_name = "Internet-facing"
    }
  }

  # Set at least empty to activate aliasIP needed by VPC native cluster
  ip_allocation_policy {
    cluster_secondary_range_name  = google_compute_subnetwork.gke-vpc-subnet.secondary_ip_range[0].range_name
    services_secondary_range_name = google_compute_subnetwork.gke-vpc-subnet.secondary_ip_range[1].range_name
  }

  maintenance_policy {
    daily_maintenance_window {
      start_time = local.cluster.daily_maintenance
    }
  }

  # disable basic auth
  master_auth {
    username = ""
    password = ""
    client_certificate_config {
      issue_client_certificate = true
    } 
  }

  addons_config {
    http_load_balancing {
      disabled = false
    }
    network_policy_config {
      disabled = false
    }
  }

  network_policy {
    enabled  = true
    provider = "CALICO"
  }
}

resource "google_container_node_pool" "preemtible_nodes" {
  name               = "${local.cluster.name}-stateful-1-21-5-gke-1302"
  cluster            = google_container_cluster.gke-cluster.name
  version            = local.preemtible.node_version
  initial_node_count = local.preemtible.initial_node_count

  management {
    auto_repair  = true 
    auto_upgrade = false
  }

  node_config {
    machine_type = local.preemtible.machine_type
    disk_size_gb = local.cluster.node_disk_size_gb
    disk_type    = local.cluster.node_disk_type
    image_type   = local.cluster.node_image_type
    oauth_scopes = local.cluster.node_permissions
    preemptible = true

    labels = {
      node_pool = "preemtible"
    }

  }
}
