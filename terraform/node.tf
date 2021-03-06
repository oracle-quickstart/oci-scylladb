locals {
  # If availability_domain_name is non empty use it,
  # otherwise use datasource and
  ad = (var.ad_name != "" ? var.ad_name : data.oci_identity_availability_domain.ad.name)

  # Logic to choose platform or mkpl image based on
  # var.marketplace_image being empty or not
  image          = var.mp_listing_resource_id
}

data "oci_identity_availability_domain" "ad" {
  compartment_id = var.tenancy_ocid
  ad_number      = var.ad_number
}

resource "oci_core_instance" "node" {
  display_name        = "scylladb-node-${count.index}"
  compartment_id      = var.compartment_ocid
  availability_domain = local.ad
  fault_domain        = "FAULT-DOMAIN-${count.index % 3 + 1}"
  shape               = var.node_shape
  subnet_id           = oci_core_subnet.subnet.id

  source_details {
    source_id   = local.image
    source_type = "image"
  }

  create_vnic_details {
    subnet_id      = oci_core_subnet.subnet.id
    hostname_label = "scylladb-node-${count.index}"
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
    user_data = base64encode(
      join(
        "\n",
        [
          "#!/usr/bin/env bash",
          file("../scripts/metadata.sh"),
          file("../scripts/disks.sh"),
          file("../scripts/node.sh"),
        ],
      ),
    )
  }

  extended_metadata = {
    config = jsonencode(
      {
        "node_shape" = var.node_shape
        "disk_count" = var.disk_count
        "disk_size"  = var.disk_size
        "node_count" = var.node_count
      },
    )
  }

  count = var.node_count
}

output "node_public_ips" {
  value = join(",", oci_core_instance.node.*.public_ip)
}

output "node_private_ips" {
  value = join(",", oci_core_instance.node.*.private_ip)
}
