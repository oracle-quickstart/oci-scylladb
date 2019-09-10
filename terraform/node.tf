locals {
  # If ad_number is non-negative use it for AD lookup, else use ad_name.
  # Allows for use of ad_number in TF deploys, and ad_name in ORM.
  # Use of max() prevents out of index lookup call.
  ad = "${var.ad_number >= 0 ? lookup(data.oci_identity_availability_domains.availability_domains.availability_domains[max(0,var.ad_number)],"name") : var.ad_name}"

  # Logic to choose platform or mkpl image based on
  # var.marketplace_image being empty or not
  platform_image = "${var.platform-images[var.region]}"
  image = "${var.mp_listing_resource_id == "" ? local.platform_image : var.mp_listing_resource_id}"
}

resource "oci_core_instance" "node" {
  display_name        = "scylladb-node-${count.index}"
  compartment_id      = "${var.compartment_ocid}"
  availability_domain = "${local.ad}"
  fault_domain        = "FAULT-DOMAIN-${(count.index%3)+1}"
  shape               = "${var.node_shape}"
  subnet_id           = "${oci_core_subnet.subnet.id}"

  source_details {
    source_id   = "${local.image}"
    source_type = "image"
  }

  create_vnic_details {
    subnet_id      = "${oci_core_subnet.subnet.id}"
    hostname_label = "scylladb-node-${count.index}"
  }

  metadata {
    ssh_authorized_keys = "${var.ssh_public_key}"

    user_data = "${base64encode(join("\n", list(
      "#!/usr/bin/env bash",
      file("../scripts/metadata.sh"),
      file("../scripts/disks.sh"),
      file("../scripts/node.sh")
    )))}"
  }

  extended_metadata {
    config = "${jsonencode(map(
      "node_shape", var.node_shape,
      "disk_count", var.disk_count,
      "disk_size", var.disk_size,
      "node_count", var.node_count
    ))}"
  }

  count = "${var.node_count}"
}

output "node server public IPs" {
  value = "${join(",", oci_core_instance.node.*.public_ip)}"
}

output "node server private IPs" {
  value = "${join(",", oci_core_instance.node.*.private_ip)}"
}
