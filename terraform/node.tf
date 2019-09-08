
resource "oci_core_instance" "node" {
  display_name        = "scylladb-node-${count.index}"
  compartment_id      = "${var.compartment_ocid}"
  availability_domain = "${lookup(data.oci_identity_availability_domains.availability_domains.availability_domains[var.ad_number],"name")}"
  fault_domain        = "FAULT-DOMAIN-${(count.index%3)+1}"
  shape               = "${var.shape}"
  subnet_id           = "${oci_core_subnet.subnet.id}"

  source_details {
    source_id   = "${var.images[var.region]}"
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
      "shape", var.shape,
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
