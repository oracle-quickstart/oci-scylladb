resource "oci_core_volume" "NodeVolume" {
  count               = "${var.node_count * var.disk_count}"
  availability_domain = "${lookup(data.oci_identity_availability_domains.availability_domains.availability_domains[var.ad_number],"name")}"
  compartment_id      = "${var.compartment_ocid}"
  display_name        = "node-${count.index % var.node_count}-volume${floor(count.index / var.node_count)}"
  size_in_gbs         = "${var.disk_size}"
}

resource "oci_core_volume_attachment" "NodeAttachment" {
  count           = "${var.node_count * var.disk_count}"
  attachment_type = "iscsi"
  instance_id     = "${oci_core_instance.node.*.id[count.index % var.node_count]}"
  volume_id       = "${oci_core_volume.NodeVolume.*.id[count.index]}"
}
