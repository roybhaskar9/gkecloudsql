provider "google" {
credentials = "${file("account.json")}"
project = "extended-legend-239009"
region = "europe-west1"
}


provider "google-beta" {

credentials = "${file("account.json")}"

project = "extended-legend-239009"

region = "europe-west1"

}

#resource "google_storage_bucket" "mybucket" {

#name = "something-unique-abra-ka-dabra"

#location = "EU"

#}


resource "google_container_cluster" "mygkecluster" {

name = "mygkecluster"

network = "default"

location = "europe-west1-b"

initial_node_count = 3

}

resource "google_compute_network" "private_network" {
provider = "google-beta"
name = "private-network"
}

resource "google_compute_global_address" "private_ip_address" {
provider = "google-beta"
name = "private-ip-address"
purpose = "VPC_PEERING"
address_type = "INTERNAL"
prefix_length = 16
network = "${google_compute_network.private_network.self_link}"
}

resource "google_service_networking_connection" "private_vpc_connection" {
provider = "google-beta"
network = "${google_compute_network.private_network.self_link}"
service = "servicenetworking.googleapis.com"
reserved_peering_ranges = ["${google_compute_global_address.private_ip_address.name}"]
}

resource "google_sql_database_instance" "instance" {
provider = "google-beta"
database_version = "POSTGRES_9_6"
name = "private-instance"
region = "us-central-1"
depends_on = ["google_service_networking_connection.private_vpc_connection"]
settings {
tier = "db-f1-micro"
ip_configuration {
ipv4_enabled = "false"
private_network = "${google_compute_network.private_network.self_link}"
}
}
}
